# frozen_string_literal: true

require 'json'

module FriendlyShipping
  module Services
    class ShipEngine
      class ParseRateEstimateResponse
        extend Dry::Monads::Result::Mixin

        class << self
          def call(response:, request:, options:)
            parsed_json = JSON.parse(response.body)
            rates = parsed_json.map do |rate|
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
                delivery_date: Time.parse(rate['estimated_delivery_date']),
                warnings: rate['warning_messages'],
                errors: rate['error_messages']
              )
            end.compact

            Success(
              ApiResult.new(
                rates,
                original_request: request,
                original_response: response
              )
            )
          end

          private

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
