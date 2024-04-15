# frozen_string_literal: true

require 'friendly_shipping/timing'

module FriendlyShipping
  module Services
    class USPSShip
      class ParseTimingsResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # Parse a timings response.
          #
          # @param request [Request] the request that was used to obtain this response
          # @param response [Response] the response that USPS returned
          # @return [Success<ApiResult<Array<Timing>>>, Failure<ApiFailure<String>>]
          def call(request:, response:)
            timings = JSON.parse(response.body).map do |timing|
              shipping_method = SHIPPING_METHODS.detect { |sm| sm.service_code == timing['mailClass'] }

              # The delivery estimate is blank if an invalid destination zip code was used
              delivery = timing.dig('delivery', 'scheduledDeliveryDateTime')
              next unless delivery

              FriendlyShipping::Timing.new(
                shipping_method: shipping_method,
                pickup: Time.parse(timing['acceptanceDateTime']),
                delivery: Time.parse(delivery),
                guaranteed: timing['delivery']['guaranteedDelivery'],
                data: {
                  notes: timing['notes'],
                  service_standard: timing['serviceStandard'],
                  service_standard_message: timing['serviceStandardMessage']
                }
              )
            end.compact

            if timings.empty?
              failure("No timings were returned. Is the destination zip correct?", request, response)
            else
              success(timings, request, response)
            end
          rescue JSON::ParserError => e
            failure(e.message, request, response)
          end

          private

          # @param timings [Array<Timing>]
          # @param request [Request]
          # @param response [Response]
          # @return [Success<ApiResult<Array<Timing>>]
          def success(timings, request, response)
            Success(
              ApiResult.new(
                timings,
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
