require 'dry/monads/result'
require 'rest-client'
require 'friendly_shipping/services/ship_engine/parse_carrier_response'
require 'friendly_shipping/services/ship_engine/serialize_label_shipment'
require 'friendly_shipping/services/ship_engine/parse_label_response'
require 'friendly_shipping/services/ship_engine/bad_request'

module FriendlyShipping
  module Services
    class ShipEngine
      include Dry::Monads::Result::Mixin

      API_BASE = "https://api.shipengine.com/v1/"
      API_PATHS = {
        carriers: "carriers",
        labels: "labels"
      }

      def initialize(token:, test: true)
        @token = token
        @test = test
      end

      def carriers
        path = API_PATHS[:carriers]
        get(path).fmap do |response|
          ParseCarrierResponse.new(response: response).call
        end
      end

      def labels(shipment)
        payload = SerializeLabelShipment.new(shipment: shipment).call.merge(test_label: test).to_json
        path = API_PATHS[:labels]
        post(path, payload).fmap do |response|
          ParseLabelResponse.new(response: response).call
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

      def post(path, payload)
        Success(
          RestClient.post(
            API_BASE + path,
            payload,
            request_headers
          )
        )
      rescue RestClient::ExceptionWithResponse => error
        if error.to_s == '400 Bad Request'
          Failure(BadRequest.new(error))
        else
          Failure(error)
        end
      end

      def request_headers
        {
          content_type: :json,
          "api-key": token
        }
      end

      attr_reader :token, :test
    end
  end
end
