# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class ParseJsonResponse
        extend Dry::Monads::Result::Mixin
        SUCCESSFUL_RESPONSE_STATUS_CODE = '1'

        class << self
          def call(request:, response:, expected_root_key:)
            api_error_message = response.headers.try(:[], :errordescription)
            response_body = JSON.parse(response.body)

            # UPS may return a 2xx status code on an unsuccessful request and include the error description in
            # the response headers, which we will consider a failure
            if api_error_message.present?
              wrap_failure(api_error_message, request, response)
            elsif response_body.nil? || response_body.keys.first != expected_root_key
              wrap_failure('Empty or unexpected root key', request, response)
            else
              Success(response_body)
            end
          rescue JSON::ParserError => e
            # when the response is not valid JSON(?!), the error description in the header is more descriptive
            wrap_failure(api_error_message || e, request, response)
          end

          private

          def wrap_failure(failure, request, response)
            Failure(
              FriendlyShipping::ApiFailure.new(
                failure,
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
