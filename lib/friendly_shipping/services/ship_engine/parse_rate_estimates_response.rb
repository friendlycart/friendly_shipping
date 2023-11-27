# frozen_string_literal: true

require 'json'

module FriendlyShipping
  module Services
    class ShipEngine
      class ParseRateEstimatesResponse
        extend Dry::Monads::Result::Mixin

        class << self
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
                service_code: rate['service_code']
              )

              amounts = get_amounts(rate)
              FriendlyShipping::Rate.new(
                shipping_method: shipping_method,
                amounts: amounts,
                remote_service_id: rate['rate_id'],
                delivery_date: rate['estimated_delivery_date'] && Time.parse(rate['estimated_delivery_date']),
                warnings: rate['warning_messages'],
                errors: rate['error_messages']
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
                ApiFailure.new(
                  error_messages,
                  original_request: request,
                  original_response: response
                )
              )
            end
          end

          private

          def valid_rates(parsed_json)
            parsed_json.map do |rate|
              ["valid", "has_warnings", "unknown"].include? rate['validation_status']
            end.any?
          end

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
