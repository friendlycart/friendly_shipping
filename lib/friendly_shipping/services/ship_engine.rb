require 'dry/monads/result'
require 'rest-client'

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
        response = RestClient.get(
          "#{API_BASE}#{API_PATHS[:carriers]}",
          {
            content_type: :json,
            "api-key": token
          }
        )
        Success(response)
      rescue RestClient::ExceptionWithResponse => error
        Failure(error)
      end

      private

      attr_reader :token
    end
  end
end
