# frozen_string_literal: true

module FriendlyShipping
  module Services
    class USPSShip
      class ParseRateEstimatesResponse
        extend Dry::Monads::Result::Mixin
        CURRENCY = Money::Currency.new('USD').freeze

        class << self
          # Parse a rate estimates response.
          #
          # @param request [Request] the request that was used to obtain this response
          # @param response [Response] the response that USPS returned
          # @return [Success<ApiResult<Array<Rate>>>, Failure<ApiFailure<String>>]
          def call(request:, response:)
            rates = JSON.parse(response.body)['rates'].map do |rate|
              shipping_method = SHIPPING_METHODS.detect { |sm| sm.service_code == rate['mailClass'] }
              total = Money.new(rate['price'] * CURRENCY.subunit_to_unit, CURRENCY)
              FriendlyShipping::Rate.new(
                amounts: { total: total },
                shipping_method: shipping_method,
                data: {
                  description: rate['description'],
                  zone: rate['zone']
                }
              )
            end

            success(rates, request, response)
          rescue JSON::ParserError, KeyError => e
            failure(e.message, request, response)
          end

          private

          # @param rates [Array<Rate>]
          # @param request [Request]
          # @param response [Response]
          # @return [Success<ApiResult<Array<Rate>>]
          def success(rates, request, response)
            Success(
              ApiResult.new(
                rates,
                original_request: request,
                original_response: response
              )
            )
          end

          # @param message [String]
          # @param request [Request]
          # @param response [Response]
          # @return [Failure<ApiFailure<String>>]
          def failure(message, request, response)
            Failure(
              ApiFailure.new(
                message,
                original_request: request,
                original_response: response
              )
            )
          end
        end
      end
    end
  end
end
