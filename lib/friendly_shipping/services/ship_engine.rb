
require 'dry/monads/result'
require 'friendly_shipping/rest_client'
require 'friendly_shipping/services/ship_engine/parse_carrier_response'
require 'friendly_shipping/services/ship_engine/serialize_label_shipment'
require 'friendly_shipping/services/ship_engine/parse_label_response'
require 'friendly_shipping/services/ship_engine/parse_void_response'

module FriendlyShipping
  module Services
    class ShipEngine
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
        path = API_BASE + API_PATHS[:carriers]
        FriendlyShipping::RestClient.get(path, request_headers).fmap do |response|
          ParseCarrierResponse.new(response: response).call
        end
      end

      def labels(shipment)
        payload = SerializeLabelShipment.new(shipment: shipment).call.merge(test_label: test).to_json
        path = API_BASE + API_PATHS[:labels]
        FriendlyShipping::RestClient.post(path, payload, request_headers).fmap do |response|
          ParseLabelResponse.new(response: response).call
        end
      end

      def void(label)
        path = "#{API_BASE}labels/#{label.id}/void"
        FriendlyShipping::RestClient.put(path, '', request_headers).bind do |response|
          ParseVoidResponse.new(response: response).call
        end
      end

      private

      attr_reader :token, :test

      def request_headers
        {
          content_type: :json,
          "api-key": token
        }
      end
    end
  end
end
