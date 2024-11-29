# frozen_string_literal: true

require 'json'

module FriendlyShipping
  module Services
    class ShipEngineLTL
      # Parses the rate quotes API response.
      class ParseQuoteResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the request to attach to the API result
          # @param response [Response] the response to parse
          # @return [Success<ApiResult<Array<Rate>>>, Failure<ApiResult<Array<String>>>] the parsed rates or errors
          def call(request:, response:)
            parsed_json = JSON.parse(response.body)
            rates = build_rates(parsed_json)
            if rates.any?
              Success(
                ApiResult.new(
                  rates,
                  original_request: request,
                  original_response: response
                )
              )
            else
              errors = parsed_json.fetch('errors', [{ 'message' => 'Unknown error' }])
              Failure(
                ApiResult.new(
                  errors.map { |e| e['message'] },
                  original_request: request,
                  original_response: response
                )
              )
            end
          end

          private

          # @param parsed_json [Hash] the parsed JSON
          # @return [Array<Rate>] the parsed rates
          def build_rates(parsed_json)
            total = build_total(parsed_json)
            return [] unless total.positive?

            [
              FriendlyShipping::Rate.new(
                shipping_method: build_shipping_method(parsed_json),
                amounts: { total: total }
              )
            ]
          end

          # @param parsed_json [Hash] the parsed JSON
          # @return [ShippingMethod] the parsed shipping method
          def build_shipping_method(parsed_json)
            description = parsed_json.dig("service", "carrier_description")
            code = parsed_json.dig("service", "code")

            FriendlyShipping::ShippingMethod.new(
              name: description,
              service_code: code,
              multi_package: true
            )
          end

          # @param parsed_json [Hash] the parsed JSON
          # @return [Money] the parsed total charges
          def build_total(parsed_json)
            total_charges = parsed_json.fetch("charges", []).detect { |e| e['type'] == "total" }
            return 0 unless total_charges

            currency = Money::Currency.new(total_charges.dig("amount", "currency"))
            value = total_charges.dig("amount", "value")
            Money.new(value * currency.subunit_to_unit, currency)
          end
        end
      end
    end
  end
end
