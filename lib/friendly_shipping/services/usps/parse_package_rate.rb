# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      class ParsePackageRate
        # USPS returns all the info about a rate in a long string with a bit of gibberish.
        ESCAPING_AND_SYMBOLS = /&lt;\S*&gt;/.freeze

        # At the beginning of the long String, USPS keeps a copy of its own name. We know we're dealing with
        # them though, so we can filter that out, too.
        LEADING_USPS = /^USPS /.freeze

        # This combines all the things we want to filter out.
        SERVICE_NAME_SUBSTITUTIONS = /#{ESCAPING_AND_SYMBOLS}|#{LEADING_USPS}/.freeze

        # Often we get a multitude of rates for the same service given some combination of
        # Box type and (see below) and "Hold for Pickup" service. This creates a regular expression
        # with groups named after the keys from the `Usps::CONTAINERS` constant.
        # Unfortunately, the keys don't correspond directly to the codes we use when serializing the
        # request.
        BOX_REGEX = {
          flat_rate_boxes: 'Flat Rate Boxes',
          large_flat_rate_box: 'Large Flat Rate Box',
          medium_flat_rate_box: 'Medium Flat Rate Box',
          small_flat_rate_box: 'Small Flat Rate Box',
          regional_rate_box_a: 'Regional Rate Box A',
          regional_rate_box_b: 'Regional Rate Box B',
          regional_rate_box_c: 'Regional Rate Box C',
          flat_rate_envelope: 'Flat Rate Envelope',
          legal_flat_rate_envelope: 'Legal Flat Rate Envelope',
          padded_flat_rate_envelope: 'Padded Flat Rate Envelope',
          gift_card_flat_rate_envelope: 'Gift Card Flat Rate Envelope',
          window_flat_rate_envelope: 'Window Flat Rate Envelope',
          small_flat_rate_envelope: 'Small Flat Rate Envelope',
          large_envelope: 'Large Envelope',
          parcel: 'Parcel',
          postcards: 'Postcards'
        }.map { |k, v| "(?<#{k}>#{v})" }.join("|").freeze

        # We use this for identifying rates that use the Hold for Pickup service.
        HOLD_FOR_PICKUP = /Hold for Pickup/i.freeze

        # For most rate options, USPS will return how many business days it takes to deliver this
        # package in the format "{1,2,3}-Day". We can filter this out using the below Regex.
        DAYS_TO_DELIVERY = /(?<days>\d)-Day/.freeze

        # When delivering to military ZIP codes, we don't actually get a timing estimate, but instead the string
        # "Military". We use this to indicate that this rate is for a military zip code in the rates' data Hash.
        MILITARY = /MILITARY/i.freeze

        # The tags used in the rate node that we get information from.
        SERVICE_CODE_TAG = 'CLASSID'
        SERVICE_NAME_TAG = 'MailService'
        RATE_TAG = 'Rate'
        COMMERCIAL_RATE_TAG = 'CommercialRate'
        COMMERCIAL_PLUS_RATE_TAG = 'CommercialPlusRate'
        DIMENSIONAL_WEIGHT_RATE = 'DimensionalWeightRate'
        FEES = './/Fees/Fee'
        CURRENCY = Money::Currency.new('USD').freeze

        class << self
          def call(rate_node, package, package_options)
            # "A mail class identifier for the postage returned. Not necessarily unique within a <Package/>."
            # (from the USPS docs). We save this on the data Hash, but do not use it for identifying shipping methods.
            service_code = rate_node.attributes[SERVICE_CODE_TAG].value

            # The long string discussed above.
            service_name = rate_node.at(SERVICE_NAME_TAG).text

            # Does this rate assume Hold for Pickup service?
            hold_for_pickup = service_name.match?(HOLD_FOR_PICKUP)

            # Is the destination a military ZIP code?
            military = service_name.match?(MILITARY)

            # If we get a days-to-delivery indication, save it in the `days_to_delivery` variable.
            days_to_delivery_match = service_name.match(DAYS_TO_DELIVERY)
            days_to_delivery = if days_to_delivery_match
                                 days_to_delivery_match.named_captures.values.first.to_i
                               end

            # Clean up the long string
            service_name.gsub!(SERVICE_NAME_SUBSTITUTIONS, '')

            # Some USPS services only offer commercial pricing. Unfortunately, USPS then returns a retail rate of 0.
            # In these cases, return the commercial rate instead of the normal rate.
            #
            # Some rates are available in both commercial and retail pricing - if we want the commercial pricing here,
            # we need to specify the commercial_pricing property on the `Physical::Package`.
            #
            commercial_rate_requested_or_rate_is_zero = package_options.commercial_pricing || rate_node.at(RATE_TAG).text.to_d.zero?
            commercial_rate_available = rate_node.at(COMMERCIAL_RATE_TAG) || rate_node.at(COMMERCIAL_PLUS_RATE_TAG)

            rate_value =
              if commercial_rate_requested_or_rate_is_zero && commercial_rate_available
                commercial_rate = rate_node.at(COMMERCIAL_RATE_TAG)&.text.to_d
                commercial_rate.zero? ? rate_node.at(COMMERCIAL_PLUS_RATE_TAG).text.to_d : commercial_rate
              else
                rate_node.at(RATE_TAG).text.to_d
              end

            # The rate expressed as a RubyMoney objext
            rate = Money.new(rate_value * CURRENCY.subunit_to_unit, CURRENCY)

            # Which shipping method does this rate belong to? We first try to match a rate to a shipping method
            # by class ID (the CLASSID attribute in the USPS API rate response). Not every shipping method
            # has a class ID defined, and a shipping method can have multiple class IDs (for example, Priority
            # Express has different class IDs for standard, hold for pickup, and Sunday/Holiday delivery).
            #
            # If we don't find a match for class ID, we next try to match a rate to a shipping method using the
            # shipping method's service code. The USPS API rate response includes a name for each rate in the
            # MailService element. We match to see if the name starts with the given value. For example:
            #   `Priority Mail Express 2-day™`
            #
            shipping_method =
              SHIPPING_METHODS.detect { |sm| sm.data[:class_ids]&.include?(service_code) } ||
              SHIPPING_METHODS.detect { |sm| service_name.tr('-', ' ').upcase.starts_with?(sm.service_code) }

            # We find out the box name using a bit of Regex magic using named captures. See the `BOX_REGEX`
            # constant above.
            box_name_match = service_name.match(/#{BOX_REGEX}/)
            box_name = box_name_match ? box_name_match.named_captures.compact.keys.last.to_sym : :variable

            dimensional_weight_rate = rate_node.at(DIMENSIONAL_WEIGHT_RATE)&.text&.to_i

            attributes = rate_node.xpath('.//Attributes/Attribute').map do |attr_node|
              # TODO
            end

            fees = rate_node.xpath(FEES).map do |fee_node|
              type = fee_node.at('FeeType').text
              price = fee_node.at('FeePrice').text.to_d
              {
                type: type,
                price: Money.new(price * CURRENCY.subunit_to_unit, CURRENCY)
              }
            end

            # Combine all the gathered information in a FriendlyShipping::Rate object.
            # Careful: This rate is only for one package within the shipment, and we get multiple
            # rates per package for the different shipping method/box/hold for pickup combinations.
            FriendlyShipping::Rate.new(
              shipping_method: shipping_method,
              amounts: { package.id => rate },
              data: {
                package: package,
                box_name: box_name,
                hold_for_pickup: hold_for_pickup,
                days_to_delivery: days_to_delivery,
                military: military,
                full_mail_service: service_name,
                service_code: service_code,
                dimensional_weight_rate: dimensional_weight_rate,
                fees: fees
              }
            )
          end
        end
      end
    end
  end
end
