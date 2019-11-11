# frozen_string_literal: true

require 'friendly_shipping/rate'
require 'friendly_shipping/api_result'
require 'friendly_shipping/services/ups_freight/parse_json_response'
require 'friendly_shipping/services/ups_freight/shipping_methods'

module FriendlyShipping
  module Services
    class UpsFreight
      class ParseFreightRateResponse
        class << self
          def call(request:, response:)
            parsed_json = ParseJSONResponse.call(response.body, 'FreightRateResponse')

            parsed_json.fmap do |json|
              service_code = json.dig("FreightRateResponse", "Service", "Code")
              shipping_method = SHIPPING_METHODS.detect { |sm| sm.service_code == service_code }
              total_shipment_charge = json.dig("FreightRateResponse", "TotalShipmentCharge")
              currency = Money::Currency.new(total_shipment_charge['CurrencyCode'])
              amount = total_shipment_charge['MonetaryValue'].to_f
              total_money = Money.new(amount * currency.subunit_to_unit, currency)
              data = {
                customer_context: json.dig("FreightRateResponse", "TransactionReference", "TransactionIdentifier"),
                commodities: Array.wrap(json.dig("FreightRateResponse", "Commodity")),
                response_body: json
              }

              days_in_transit = json.dig("FreightRateResponse", "TimeInTransit", "DaysInTransit")
              if days_in_transit
                data[:days_in_transit] = days_in_transit.to_i
              end

              FriendlyShipping::ApiResult.new(
                [
                  FriendlyShipping::Rate.new(
                    amounts: {
                      total: total_money
                    },
                    shipping_method: shipping_method,
                    data: data
                  )
                ],
                original_request: request,
                original_response: response
              )
            end
          end
        end
      end
    end
  end
end
