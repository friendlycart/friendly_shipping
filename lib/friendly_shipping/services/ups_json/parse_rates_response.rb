# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class ParseRatesResponse
        class << self
          def call(request:, response:, shipment:)
            parsed_response = ParseJsonResponse.call(
              request: request,
              response: response,
              expected_root_key: 'RateResponse'
            )
            parsed_response.fmap do |parsing_result|
              FriendlyShipping::ApiResult.new(
                build_rates(parsing_result, shipment),
                original_request: request,
                original_response: response
              )
            end
          end

          def build_rates(rates_result, shipment)
            rates = []

            rates_result.dig('RateResponse', 'RatedShipment').each do |rated_shipment|
              service_code = rated_shipment.dig('Service', 'Code')
              shipping_method = CARRIER.shipping_methods.detect do |sm|
                sm.service_code == service_code && shipment.origin.country.in?(sm.origin_countries)
              end
              days_to_delivery = rated_shipment.dig('GuaranteedDelivery', 'BusinessDaysInTransit').to_i
              total_cost = ParseMoneyHash.call(rated_shipment['TotalCharges'], 'TotalCharges')
              insurance_price = ParseMoneyHash.call(rated_shipment['ServiceOptionsCharges'], 'ServiceOptionsCharges')
              negotiated_rate = ParseMoneyHash.call(rated_shipment.dig('NegotiatedRates', 'NetSummaryCharges', 'GrandTotal'), 'GrandTotal')
              negotiated_charges = ParseMoneyHash.call(rated_shipment.dig('NegotiatedRates', 'ItemizedCharges'), 'ItemizedCharges')

              itemized_charges = rated_shipment['ItemizedCharges'].is_a?(Hash) ? [rated_shipment['ItemizedCharges']] : rated_shipment['ItemizedCharges']
              itemized_charges = itemized_charges.map do |charge|
                ParseMoneyHash.call(charge, 'MonetaryValue')
              end

              rated_shipment_warnings = rated_shipment['RatedShipmentAlert'].is_a?(Hash) ? [rated_shipment['RatedShipmentAlert']] : rated_shipment['RatedShipmentAlert']
              rated_shipment_warnings = rated_shipment_warnings.map { |alert| alert["Description"] }
              if rated_shipment_warnings.any? { |e| e.match?(/to Residential/) }
                new_address_type = 'residential'
              elsif rated_shipment_warnings.any? { |e| e.match?(/to Commercial/) }
                new_address_type = 'commercial'
              end

              rates << FriendlyShipping::Rate.new(
                shipping_method:,
                amounts: { total: total_cost },
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
            rates
          end

          private

          def build_packages(rated_shipment)
            package_array = rated_shipment['RatedPackage'].is_a?(Hash) ? [rated_shipment['RatedPackage']] : rated_shipment['RatedPackage']
            package_array.map do |rated_package|
              currency_code = rated_package.dig('TotalCharges', 'CurrencyCode')
              {
                transportation_charges: ParseMoneyHash.call(rated_package['TransportationCharges'], 'TransportationCharges'),
                base_service_charge: ParseMoneyHash.call(rated_package['BaseServiceCharge'], 'BaseServiceCharge'),
                service_options_charges: ParseMoneyHash.call(rated_package['ServiceOptionsCharges'], 'ServiceOptionsCharges'),
                itemized_charges: extract_charges(rated_package['ItemizedCharges'], 'ItemizedCharges'),
                total_charges: ParseMoneyHash.call(rated_package['TotalCharges'], 'TotalCharges'),
                negotiated_charges: extract_charges(rated_package.dig('NegotiatedRateCharges', 'ItemizedCharges'), 'ItemizedCharges'),
                rate_modifiers: extract_modifiers(rated_package['RateModifier'], currency_code: currency_code),
                weight: BigDecimal(rated_package['Weight']),
                billing_weight: BigDecimal(rated_package.dig('BillingWeight', 'Weight'))
              }.compact
            end
          end

          def extract_charges(charges, key_name)
            charges&.map do |charge|
              ParseMoneyHash.call(charge, key_name)
            end&.compact
          end

          def extract_modifiers(modifiers, currency_code:)
            modifiers = [modifiers] if modifiers.is_a?(Hash)
            modifiers&.map do |modifier|
              ParseRateModifierHash.call(modifier, currency_code:)
            end&.compact
          end
        end
      end
    end
  end
end
