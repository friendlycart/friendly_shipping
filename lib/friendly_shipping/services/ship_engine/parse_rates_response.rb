# frozen_string_literal: true

require 'json'

module FriendlyShipping
  module Services
    class ShipEngine
      # Parses the rates API response.
      class ParseRatesResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the request to attach to the API result
          # @param response [Response] the response to parse
          # @param options [RatesOptions] the options to use when parsing
          # @return [Success<ApiResult<Array<Rate>>>, Failure<ApiFailure<String>>] the parsed rates or error
          def call(request:, response:, options:)
            parsed_json = JSON.parse(response.body)
            rates = build_rates(parsed_json, options)
            if rates.any?
              Success(
                ApiResult.new(
                  rates,
                  original_request: request,
                  original_response: response
                )
              )
            else
              error = parsed_json.dig("rate_response", "errors", 0, "message") || "Unknown error"
              Failure(
                ApiFailure.new(
                  error,
                  original_request: request,
                  original_response: response
                )
              )
            end
          end

          private

          # @param parsed_json [String] the parsed JSON
          # @param options [RateOptions] the options to use when parsing
          # @return [Array<Rate>] the parsed rates
          def build_rates(parsed_json, options)
            returned_rates = parsed_json.dig('rate_response', 'rates')
            return [] unless returned_rates

            returned_rates.map do |rate|
              if rate['validation_status'] == 'invalid'
                error_messages.concat rate['error_messages']
                next
              end

              carrier = options.carriers.detect { |c| c.id == rate['carrier_id'] }
              next unless carrier

              shipping_method = FriendlyShipping::ShippingMethod.new(
                carrier: carrier,
                service_code: rate['service_code']
              )

              # validate service code is available/matches shipping method?

              amounts = get_amounts(rate)
              FriendlyShipping::Rate.new(
                shipping_method: shipping_method,
                amounts: amounts,
                remote_service_id: rate['rate_id'],
                delivery_date: rate['estimated_delivery_date'] && Time.parse(rate['estimated_delivery_date']),
                warnings: rate['warning_messages'],
                errors: rate['error_messages'],
                data: {
                  package_type: rate['package_type'],
                  delivery_days: rate['delivery_days'],
                  carrier_delivery_days: rate['carrier_delivery_days'],
                  negotiated_rate: rate['negotiated_rate'],
                  trackable: rate['trackable'],
                  validation_status: rate['validation_status']
                }
              )
            end.compact
          end

          # @param rate_hash [Hash] the rate hash
          # @return [Hash<Symbol,Money>] the amounts in the hash
          def get_amounts(rate_hash)
            [:shipping, :other, :insurance, :confirmation].to_h do |name|
              currency = Money::Currency.new(rate_hash["#{name}_amount"]["currency"])
              amount = rate_hash["#{name}_amount"]["amount"] * currency.subunit_to_unit
              [
                name,
                Money.new(amount, currency)
              ]
            end
          end
        end
      end
    end
  end
end
