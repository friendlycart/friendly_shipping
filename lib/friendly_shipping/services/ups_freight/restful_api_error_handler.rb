# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class RestfulApiErrorHandler
        extend Dry::Monads::Result::Mixin

        def self.call(error)
          parsed_json = JSON.parse(error.response.body)
          errors = parsed_json.dig('response', 'errors')

          failure_string = errors.map do |err|
            status = err['code']
            desc = err['message']
            [status, desc].compact.join(": ").presence || 'UPS could not process the request.'
          end.join("\n")

          Failure(failure_string)
        end
      end
    end
  end
end
