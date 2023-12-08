# frozen_string_literal: true

require 'friendly_shipping/rate'
require 'friendly_shipping/api_result'
require 'friendly_shipping/services/tforce_freight/shipping_methods'

module FriendlyShipping
  module Services
    class TForceFreight
      class ParseRatesResponse
        class << self
          def call(request:, response:)
            json = JSON.parse(response.body)
            transaction_id = json.dig("summary", "transactionReference", "transactionId")

            rates = json['detail'].map do |detail|
              service_code = detail.dig("service", "code")
              shipping_method = SHIPPING_METHODS.detect { |sm| sm.service_code == service_code }

              total_amount = detail.dig("shipmentCharges", "total", "value")
              total_currency = detail.dig("shipmentCharges", "total", "currency")
              total = Money.new(total_amount.to_f * 100, total_currency)

              rates = detail['rate']
              data = rates.each_with_object({}) do |rate, result|
                result[rate['code'].downcase.to_sym] = rate['value'].to_f
              end

              data.merge(
                customer_context: transaction_id,
                commodities: Array.wrap(json['commodities'])
              )

              days_in_transit = detail.dig("timeInTransit", "timeInTransit")
              data[:days_in_transit] = days_in_transit.to_i if days_in_transit

              FriendlyShipping::Rate.new(
                amounts: { total: total },
                shipping_method: shipping_method,
                data: data
              )
            end

            FriendlyShipping::ApiResult.new(
              rates,
              original_request: request,
              original_response: response
            )
          end
        end
      end
    end
  end
end
