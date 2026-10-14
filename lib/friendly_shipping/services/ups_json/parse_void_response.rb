# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Parses the response of a void shipment request.
      class ParseVoidResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the request that was sent
          # @param response [Response] the response received
          # @return [Result<ApiResult<Hash>>] the VoidShipmentResponse hash from the response body
          def call(request:, response:)
            parsed_response = ParseJsonResponse.call(
              request: request,
              response: response,
              expected_root_key: "VoidShipmentResponse"
            )

            parsed_response.bind do |void_response|
              result = void_response["VoidShipmentResponse"]
              Success(
                FriendlyShipping::ApiResult.new(
                  result,
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
end
