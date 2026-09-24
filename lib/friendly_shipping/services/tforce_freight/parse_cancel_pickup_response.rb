# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Parses a cancel pickup response into an `ApiResult`.
      class ParseCancelPickupResponse
        extend Dry::Monads::Result::Mixin

        # The response status code that indicates success.
        SUCCESS_CODE = "1"

        class << self
          # @param request [Request] the original request
          # @param response [RestClient::Response] the response to parse
          # @return [Success<ApiResult<Hash>>, Failure<ApiResult<String>>] the parsed result on
          #   success, or a failure containing the error message
          def call(request:, response:)
            json = JSON.parse(response.body)

            code = json.dig("responseStatus", "code")
            description = json.dig("responseStatus", "description")

            unless code == SUCCESS_CODE
              return Failure(
                ApiResult.new(
                  [code, description].compact.join(": "),
                  original_request: request,
                  original_response: response
                )
              )
            end

            Success(
              ApiResult.new(
                {
                  response_status_code: code,
                  response_status_description: description,
                  transaction_id: json.dig("transactionReference", "transactionId"),
                  confirmation_number: json.dig("transactionReference", "confirmationNumber")
                },
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
