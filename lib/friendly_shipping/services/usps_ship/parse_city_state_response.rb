# frozen_string_literal: true

module FriendlyShipping
  module Services
    class USPSShip
      class ParseCityStateResponse
        extend Dry::Monads::Result::Mixin

        USA = Carmen::Country.coded("USA")

        class << self
          # Parse a city/state response.
          #
          # @param request [Request] the request that was used to obtain this response
          # @param response [Response] the response that USPS returned
          # @return [Success<ApiResult<Physical::Location>>, Failure<ApiResult<String>>]
          def call(request:, response:)
            city_state = JSON.parse(response.body)

            if city_state['error']
              failure(
                api_error("Error: #{city_state.dig('error', 'message')}"),
                request,
                response
              )
            else
              success(
                Physical::Location.new(
                  city: city_state['city'],
                  region: city_state['state'],
                  zip: city_state['ZIPCode'],
                  country: USA
                ),
                request,
                response
              )
            end
          rescue JSON::ParserError => e
            failure(e, request, response)
          end

          # @param location [Physical::Location]
          # @param request [Request]
          # @param response [Response]
          # @return [Success<ApiResult<Physical::Location>>]
          def success(location, request, response)
            Success(
              ApiResult.new(
                location,
                original_request: request,
                original_response: response
              )
            )
          end

          # @param error [JSON::ParserError, FriendlyShipping::ApiError]
          # @param request [Request]
          # @param response [Response]
          # @return [Failure<ApiResult>]
          def failure(error, request, response)
            Failure(
              ApiResult.new(
                error,
                original_request: request,
                original_response: response
              )
            )
          end

          private

          def api_error(message)
            FriendlyShipping::ApiError.new(nil, message)
          end
        end
      end
    end
  end
end
