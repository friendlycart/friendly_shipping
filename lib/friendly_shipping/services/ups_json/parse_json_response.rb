# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class ParseJsonResponse
        extend Dry::Monads::Result::Mixin
        SUCCESSFUL_RESPONSE_STATUS_CODE = '1'
        UNEXPECTED_ROOT_KEY_STRING = 'Empty or unexpected root key'

        class << self
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

          def api_error(message)
            FriendlyShipping::ApiError.new(nil, message)
          end

          def wrap_failure(error, request, response)
            Failure(
              FriendlyShipping::ApiFailure.new(
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
