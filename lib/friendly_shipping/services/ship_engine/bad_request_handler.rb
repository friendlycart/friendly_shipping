# frozen_string_literal: true

require 'friendly_shipping/services/ship_engine/bad_request'

module FriendlyShipping
  module Services
    class ShipEngine
      class BadRequestHandler
        extend Dry::Monads::Result::Mixin

        def self.call(error)
          if error.http_code == 400
            Failure(BadRequest.new(error))
          else
            Failure(error)
          end
        end
      end
    end
  end
end
