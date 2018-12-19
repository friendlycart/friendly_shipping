require 'dry/monads/result'
require 'rest-client'
require 'friendly_shipping/services/ship_engine/parse_carrier_response'

module FriendlyShipping
  module Services
    class ShipEngine
      include Dry::Monads::Result::Mixin

      API_BASE = "https://api.shipengine.com/v1/"
      API_PATHS = {
        carriers: "carriers"
      }

      def initialize(token:)
        @token = token
      end

      def carriers
        path = API_PATHS[:carriers]
        get(path).fmap do |response|
          ParseCarrierResponse.new(response: response).call
        end
      end

      private

      def get(path)
        Success(
          RestClient.get(
            API_BASE + path,
            request_headers
          )
        )
      rescue RestClient::ExceptionWithResponse => error
        Failure(error)
      end

      def request_headers
        {
          content_type: :json,
          "api-key": token
        }
      end

      attr_reader :token
    end
  end
end
