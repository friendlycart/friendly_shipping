
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

      def initialize(token:, test: true, client: FriendlyShipping::RestClient)
        @token = token
        @test = test
        @client = client
      end

      def carriers
        path = API_BASE + API_PATHS[:carriers]
        FriendlyShipping::RestClient.get(path, request_headers).fmap do |response|
          ParseCarrierResponse.new(response: response).call
        end
      end

      def labels(shipment)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:labels],
          body: SerializeLabelShipment.new(shipment: shipment).call.merge(test_label: test).to_json,
          headers: request_headers
        )
        client.post(request).fmap do |response|
          ParseLabelResponse.(response.body)
        end
      end

      def void(label)
        path = "#{API_BASE}labels/#{label.id}/void"
        FriendlyShipping::RestClient.put(path, '', request_headers).bind do |response|
          ParseVoidResponse.new(response: response).call
        end
      end

      private

      attr_reader :token, :test, :client

      def request_headers
        {
          content_type: :json,
          "api-key": token
        }
      end
    end
  end
end
