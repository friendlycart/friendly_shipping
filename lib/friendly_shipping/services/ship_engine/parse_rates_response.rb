# frozen_string_literal: true

require 'json'

module FriendlyShipping
  module Services
    class ShipEngine
      class ParseRatesResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param [FriendlyShipping::Request] request
          # @param [FriendlyShipping::Response] response
          # @return [
          #   Dry::Monads::Success<FriendlyShipping::ApiResult>,
          #   Dry::Monads::Failure<FriendlyShipping::ApiFailure>
          # ]
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

          CURRENCY = Money::Currency.new('USD').freeze

          # @param [String] parsed_json
          # @return [Array<FriendlyShipping::Rate>]
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
                errors: rate['error_messages']
              )
            end.compact
          end

          def get_amounts(rate_hash)
            [:shipping, :other, :insurance, :confirmation].map do |name|
              currency = Money::Currency.new(rate_hash["#{name}_amount"]["currency"])
              amount = rate_hash["#{name}_amount"]["amount"] * currency.subunit_to_unit
              [
                name,
                Money.new(amount, currency)
              ]
            end.to_h
          end
        end
      end
    end
  end
end
