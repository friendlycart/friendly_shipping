# frozen_string_literal: true

require 'json'
require 'friendly_shipping/services/rl/shipping_methods'

module FriendlyShipping
  module Services
    class RL
      class ParseRateQuoteResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param [FriendlyShipping::Request] request
          # @param [FriendlyShipping::Response] response
          # @return [
          #   Dry::Monads::Success<FriendlyShipping::ApiResult>,
          #   Dry::Monads::Failure<FriendlyShipping::ApiResult>
          # ]
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
              errors = parsed_json.fetch('Errors', [{ 'ErrorMessage' => 'Unknown error' }])
              Failure(
                ApiResult.new(
                  errors.map { |e| e['ErrorMessage'] },
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
          def build_rates(parsed_json)
            service_levels = parsed_json.dig('RateQuote', 'ServiceLevels')
            return [] unless service_levels

            service_levels.map do |service_level|
              shipping_method = SHIPPING_METHODS.detect { |sm| sm.service_code == service_level['Code'] }
              total = Money.new(service_level['NetCharge'].delete('$,.'), CURRENCY)
              FriendlyShipping::Rate.new(
                shipping_method: shipping_method,
                amounts: { total: total }
              )
            end
          end
        end
      end
    end
  end
end
