# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      # Parses the API response for voiding a label.
      class ParseVoidResponse
        extend Dry::Monads::Result::Mixin

        # @param request [Request] the request to attach to the API result
        # @param response [Response] the response to parse
        # @return [Success<ApiResult<String>>, Failure<ApiFailure<String>>] the success or failure message
        def self.call(request:, response:)
          parsed_json = JSON.parse(response.body)
          approved, message = parsed_json["approved"], parsed_json["message"]
          if approved
            Success(
              ApiResult.new(message, original_request: request, original_response: response)
            )
          else
            Failure(
              ApiFailure.new(message, original_request: request, original_response: response)
            )
          end
        end
      end
    end
  end
end
