# frozen_string_literal: true

require 'friendly_shipping/bad_request'

module FriendlyShipping
  module Services
    class ShipEngine
      class ParseVoidResponse
        include Dry::Monads::Result::Mixin

        attr_reader :response

        def initialize(response:)
          @response = response
        end

        def call
          parsed_json = JSON.parse(response.body)
          approved, message = parsed_json["approved"], parsed_json["message"]
          approved ? Success(message) : Failure(message)
        end
      end
    end
  end
end
