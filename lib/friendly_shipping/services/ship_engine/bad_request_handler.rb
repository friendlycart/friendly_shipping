# frozen_string_literal: true

require 'friendly_shipping/services/ship_engine/bad_request'

module FriendlyShipping
  module Services
    class ShipEngine
      class BadRequestHandler
        extend Dry::Monads::Result::Mixin

        def self.call(error, original_request: nil, original_response: nil)
          if error.http_code == 400
            Failure(
              ApiFailure.new(
                BadRequest.new(error),
                original_request: original_request,
                original_response: original_response
              )
            )
          else
            Failure(
              ApiFailure.new(
                error,
                original_request: original_request,
                original_response: original_response
              )
            )
          end
        end
      end
    end
  end
end
