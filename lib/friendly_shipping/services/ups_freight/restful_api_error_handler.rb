# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class RestfulApiErrorHandler
        extend Dry::Monads::Result::Mixin

        def self.call(error, original_request: nil, original_response: nil)
          parsed_json = JSON.parse(error.response.body)
          errors = parsed_json.dig('response', 'errors')

          failure_string = errors.map do |err|
            status = err['code']
            desc = err['message']
            [status, desc].compact.join(": ").presence || 'UPS could not process the request.'
          end.join("\n")

          Failure(
            ApiFailure.new(
              failure_string,
              original_request: original_request,
              original_response: original_response
            )
          )
        end
      end
    end
  end
end
