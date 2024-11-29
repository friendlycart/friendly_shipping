# frozen_string_literal: true

require 'json'

module FriendlyShipping
  module Services
    class ShipEngine
      # Parses the rate estimates API response.
      class ParseRateEstimatesResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the request to attach to the API result
          # @param response [Response] the response to parse
          # @param options [RateEstimatesOptions] the options to use when parsing
          # @return [Success<ApiResult<Array<Rate>>>, Failure<ApiResult<Array<String>>>] the parsed rate estimates or errors
          def call(response:, request:, options:)
            error_messages = []
            parsed_json = JSON.parse(response.body)
            rates = parsed_json.map do |rate|
              if rate['validation_status'] == 'invalid'
                error_messages.concat rate['error_messages']
                next
              end

              carrier = options.carriers.detect { |c| c.id == rate['carrier_id'] }
              next unless carrier

              shipping_method = FriendlyShipping::ShippingMethod.new(
                carrier: carrier,
                name: rate['service_type'],
                service_code: rate['service_code']
              )

              amounts = get_amounts(rate)
              FriendlyShipping::Rate.new(
                shipping_method: shipping_method,
                amounts: amounts,
                remote_service_id: rate['rate_id'],
                pickup_date: rate['ship_date'] && Time.parse(rate['ship_date']),
                delivery_date: rate['estimated_delivery_date'] && Time.parse(rate['estimated_delivery_date']),
                guaranteed: rate['guaranteed_service'],
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

            if valid_rates(parsed_json)
              Success(
                ApiResult.new(
                  rates,
                  original_request: request,
                  original_response: response
                )
              )
            else
              Failure(
                ApiResult.new(
                  error_messages,
                  original_request: request,
                  original_response: response
                )
              )
            end
          end

          private

          # @param parsed_json [Hash] the parsed JSON
          # @return [Boolean] whether the rate estimates are valid
          def valid_rates(parsed_json)
            parsed_json.map do |rate|
              %w[valid has_warnings unknown].include? rate['validation_status']
            end.any?
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
