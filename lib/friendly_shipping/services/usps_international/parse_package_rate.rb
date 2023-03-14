# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UspsInternational
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
          flat_rate_boxes: 'Flat Rate Box',
          large_flat_rate_box: 'Large Flat Rate Box',
          medium_flat_rate_box: 'Medium Flat Rate Box',
          small_flat_rate_box: 'Small Flat Rate Box',
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

        # The tags used in the rate node that we get information from.
        SERVICE_CODE_TAG = 'ID'
        SERVICE_NAME_TAG = 'SvcDescription'
        RATE_TAG = 'Postage'
        COMMERCIAL_RATE_TAG = 'CommercialPostage'
        COMMERCIAL_PLUS_RATE_TAG = 'CommercialPlusPostage'
        CURRENCY = Money::Currency.new('USD').freeze

        class << self
          def call(rate_node, package, package_options)
            # "A mail class identifier for the postage returned. Not necessarily unique within a <Package/>."
            # (from the USPS docs). We save this on the data Hash, but do not use it for identifying shipping methods.
            service_code = rate_node.attributes[SERVICE_CODE_TAG].value

            # The long string discussed above.
            service_name = rate_node.at(SERVICE_NAME_TAG).text

            days_to_delivery = rate_node.at('GuaranteeAvailability')&.text

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
                rate_node.at(COMMERCIAL_RATE_TAG)&.text&.to_d || rate_node.at(COMMERCIAL_PLUS_RATE_TAG).text.to_d
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
            shipping_method = SHIPPING_METHODS.find { |sm| sm.service_code == service_code }

            # We find out the box name using a bit of Regex magic using named captures. See the `BOX_REGEX`
            # constant above.
            box_name_match = service_name.match(/#{BOX_REGEX}/)
            box_name = box_name_match ? box_name_match.named_captures.compact.keys.last.to_sym : :variable

            # Combine all the gathered information in a FriendlyShipping::Rate object.
            # Careful: This rate is only for one package within the shipment, and we get multiple
            # rates per package for the different shipping method/box/hold for pickup combinations.
            FriendlyShipping::Rate.new(
              shipping_method: shipping_method,
              amounts: { package.id => rate },
              data: {
                package: package,
                box_name: box_name,
                days_to_delivery: days_to_delivery,
                full_mail_service: service_name,
                service_code: service_code,
              }
            )
          end
        end
      end
    end
  end
end
