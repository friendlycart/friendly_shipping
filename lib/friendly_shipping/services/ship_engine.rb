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
        path = API_PATHS[:carriers]
        Success(get(path))
      rescue RestClient::ExceptionWithResponse => error
        Failure(error)
      end

      private

      def get(path)
        RestClient.get(
          API_BASE + path,
          request_headers
        )
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
