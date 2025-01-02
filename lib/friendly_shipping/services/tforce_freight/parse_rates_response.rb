# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Parses a rates response into an `ApiResult`.
      class ParseRatesResponse
        class << self
          # @param request [Request] the original request
          # @param response [RestClient::Response] the response to parse
          # @return [ApiResult<Array<Rate>>] the parsed result
          def call(request:, response:)
            json = JSON.parse(response.body)
            transaction_id = json.dig("summary", "transactionReference", "transactionId")

            rates = json['detail'].map do |detail|
              service_code = detail.dig("service", "code")
              shipping_method = SHIPPING_METHODS.detect { |sm| sm.service_code == service_code }

              total_amount = detail.dig("shipmentCharges", "total", "value")
              total_currency = detail.dig("shipmentCharges", "total", "currency")
              total = Money.new(total_amount.to_f * 100, total_currency)

              data = {
                customer_context: transaction_id,
                commodities: Array.wrap(json['commodities']),
                cost_breakdown: detail['rate'].map { |rate| rate.slice(*%w[code description value unit]) }
              }

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
