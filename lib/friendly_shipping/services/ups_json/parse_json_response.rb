# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class ParseJsonResponse
        extend Dry::Monads::Result::Mixin
        SUCCESSFUL_RESPONSE_STATUS_CODE = '1'

        class << self
          def call(request:, response:, expected_root_key:)
            response_body = JSON.parse(response.body)

            if response_body.nil? || response_body.keys.first != expected_root_key
              wrap_failure('Empty or unexpected root key', request, response)
            elsif request_successful?(response_body, expected_root_key)
              Success(response_body)
            else
              wrap_failure(error_message(response_body), request, response)
            end
          rescue JSON::ParserError => e
            wrap_failure(e, request, response)
          end

          private

          def request_successful?(response_body, expected_root_key)
            response_body.dig(expected_root_key, 'Response', 'ResponseStatus', 'Code') == SUCCESSFUL_RESPONSE_STATUS_CODE
          end

          def error_message(response_body)
            errors = response_body.dig('response', 'errors')
            errors.join(", ").presence || 'UPS could not process the request.'
          end

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
