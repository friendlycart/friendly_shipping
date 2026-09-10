# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Parses the response from the R+L API when cancelling a pickup request.
      class ParseCancelPickupResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the request to attach to the API result
          # @param response [Response] the response to parse
          # @return [Success<ApiResult<Array<String>>>, Failure<ApiResult<Array<String>>>] the
          #   messages returned by the API, or the error messages if the cancellation failed
          def call(request:, response:)
            parsed_json = JSON.parse(response.body)
            errors = parsed_json.fetch('Errors', []) || []
            if errors.empty?
              Success(
                ApiResult.new(
                  parsed_json.fetch('Messages', []),
                  original_request: request,
                  original_response: response
                )
              )
            else
              Failure(
                ApiResult.new(
                  errors.map { |e| e['ErrorMessage'] },
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
