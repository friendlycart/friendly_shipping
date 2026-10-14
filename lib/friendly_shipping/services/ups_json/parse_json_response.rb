# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Parses a UPS JSON response body and checks it for errors and the expected root key.
      class ParseJsonResponse
        extend Dry::Monads::Result::Mixin

        # The response status code UPS uses to indicate success.
        SUCCESSFUL_RESPONSE_STATUS_CODE = '1'
        # The error message used when the response body is empty or its first key is not the expected root key.
        UNEXPECTED_ROOT_KEY_STRING = 'Empty or unexpected root key'

        class << self
          # @param request [Request] the request that was sent
          # @param response [Response] the response received
          # @param expected_root_key [String] the key that must be the first key of the response body
          # @return [Result<Hash, ApiResult<ApiError>>] the parsed body on success, otherwise a failure wrapping
          #   an error
          def call(request:, response:, expected_root_key:)
            api_error_message = response.headers.try(:[], :errordescription)
            response_body = JSON.parse(response.body)

            # UPS may return a 2xx status code on an unsuccessful request and include the error description in
            # the response headers, which we will consider a failure
            if api_error_message.present?
              wrap_failure(api_error(api_error_message), request, response)
            elsif response_body.nil? || response_body.keys.first != expected_root_key
              wrap_failure(api_error(UNEXPECTED_ROOT_KEY_STRING), request, response)
            else
              Success(response_body)
            end
          rescue JSON::ParserError => e
            # when the response is not valid JSON(?!), the error description in the header is more descriptive
            return wrap_failure(api_error(api_error_message), request, response) if api_error_message

            wrap_failure(e, request, response)
          end

          private

          # @param message [String] the error message
          # @return [ApiError] an error with the given message
          def api_error(message)
            FriendlyShipping::ApiError.new(nil, message)
          end

          # @param error [StandardError] the error to wrap
          # @param request [Request] the request that was sent
          # @param response [Response] the response received
          # @return [Failure<ApiResult>] a failure wrapping the error
          def wrap_failure(error, request, response)
            Failure(
              FriendlyShipping::ApiResult.new(
                error,
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
