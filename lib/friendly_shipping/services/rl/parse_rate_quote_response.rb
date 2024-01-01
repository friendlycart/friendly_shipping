# frozen_string_literal: true

require 'json'
require 'friendly_shipping/services/rl/shipping_methods'

module FriendlyShipping
  module Services
    class RL
      # Parses the response from the R+L API when getting rate quotes.
      class ParseRateQuoteResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the request to attach to the API result
          # @param response [Response] the response to parse
          # @return [Success<ApiResult>, Failure<ApiResult>] the parsed rates
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

          # The currency to use when parsing the rate quotes.
          CURRENCY = Money::Currency.new('USD').freeze

          # Builds {Rate} instances from the parsed JSON.
          #
          # @param parsed_json [String] the parsed JSON
          # @return [Array<Rate>] the parsed rates
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
