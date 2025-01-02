# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class ParseRateResponse
        class << self
          def call(request:, response:, shipment:)
            parsing_result = ParseXMLResponse.call(
              request: request,
              response: response,
              expected_root_tag: 'RatingServiceSelectionResponse'
            )
            parsing_result.fmap do |xml|
              FriendlyShipping::ApiResult.new(
                build_rates(xml, shipment),
                original_request: request,
                original_response: response
              )
            end
          end

          def build_rates(xml, shipment)
            xml.root.css('> RatedShipment').map do |rated_shipment|
              service_code = rated_shipment.at('Service/Code').text
              shipping_method = CARRIER.shipping_methods.detect do |sm|
                sm.service_code == service_code && shipment.origin.country.in?(sm.origin_countries)
              end
              days_to_delivery = rated_shipment.at('GuaranteedDaysToDelivery').text.to_i

              total = ParseMoneyElement.call(rated_shipment.at('TotalCharges')).last
              insurance_price = ParseMoneyElement.call(rated_shipment.at('ServiceOptionsCharges'))&.last
              negotiated_rate = ParseMoneyElement.call(
                rated_shipment.at('NegotiatedRates/NetSummaryCharges/GrandTotal')
              )&.last
              negotiated_charges = extract_charges(rated_shipment.xpath('NegotiatedRates/ItemizedCharges'))
              itemized_charges = extract_charges(rated_shipment.xpath('ItemizedCharges'))

              rated_shipment_warnings = rated_shipment.css('RatedShipmentWarning').map { |e| e.text.strip }
              if rated_shipment_warnings.any? { |e| e.match?(/to Residential/) }
                new_address_type = 'residential'
              elsif rated_shipment_warnings.any? { |e| e.match?(/to Commercial/) }
                new_address_type = 'commercial'
              end

              FriendlyShipping::Rate.new(
                shipping_method: shipping_method,
                amounts: { total: total },
                warnings: rated_shipment_warnings,
                errors: [],
                data: {
                  insurance_price: insurance_price,
                  negotiated_rate: negotiated_rate,
                  negotiated_charges: negotiated_charges,
                  days_to_delivery: days_to_delivery,
                  new_address_type: new_address_type,
                  itemized_charges: itemized_charges,
                  packages: build_packages(rated_shipment)
                }.compact
              )
            end
          end

          private

          def build_packages(rated_shipment)
            rated_shipment.css('RatedPackage').map do |rated_package|
              currency_code = rated_package.at('TotalCharges/CurrencyCode').text
              {
                transportation_charges: ParseMoneyElement.call(rated_package.at('TransportationCharges'))&.last,
                base_service_charge: ParseMoneyElement.call(rated_package.at('BaseServiceCharge'))&.last,
                service_options_charges: ParseMoneyElement.call(rated_package.at('ServiceOptionsCharges'))&.last,
                itemized_charges: extract_charges(rated_package.xpath('ItemizedCharges')),
                total_charges: ParseMoneyElement.call(rated_package.at('TotalCharges'))&.last,
                negotiated_charges: extract_charges(rated_package.xpath('NegotiatedCharges/ItemizedCharges')),
                rate_modifiers: extract_modifiers(rated_package.xpath('RateModifier'), currency_code: currency_code),
                weight: BigDecimal(rated_package.at('Weight').text),
                billing_weight: BigDecimal(rated_package.at('BillingWeight/Weight').text)
              }.compact
            end
          end

          def extract_charges(node)
            node.map do |element|
              ParseMoneyElement.call(element)
            end.compact.to_h
          end

          # @param [Nokogiri::XML::NodeSet] node The RateModifier node set from the source XML
          # @param [String] currency_code The currency code for the modifier amounts (i.e. 'USD')
          # @return [Array<Hash>]
          def extract_modifiers(node, currency_code:)
            node.map do |element|
              ParseModifierElement.call(element, currency_code: currency_code)
            end.compact.to_h
          end
        end
      end
    end
  end
end
