
require 'dry/monads/result'
require 'friendly_shipping/services/ship_engine/client'
require 'friendly_shipping/services/ship_engine/parse_carrier_response'
require 'friendly_shipping/services/ship_engine/serialize_label_shipment'
require 'friendly_shipping/services/ship_engine/serialize_rate_estimate_request'
require 'friendly_shipping/services/ship_engine/parse_label_response'
require 'friendly_shipping/services/ship_engine/parse_void_response'
require 'friendly_shipping/services/ship_engine/parse_rate_estimate_response'

module FriendlyShipping
  module Services
    class ShipEngine
      API_BASE = "https://api.shipengine.com/v1/"
      API_PATHS = {
        carriers: "carriers",
        labels: "labels"
      }

      def initialize(token:, test: true, client: Client)
        @token = token
        @test = test
        @client = client
      end

      def carriers
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:carriers],
          headers: request_headers
        )
        client.get(request).fmap do |response|
          ParseCarrierResponse.new(response: response).call
        end
      end

      def rate_estimates(shipment, carriers)
        request = FriendlyShipping::Request.new(
          url: API_BASE + 'rates/estimate',
          body: SerializeRateEstimateRequest.(shipment: shipment, carriers: carriers).to_json,
          headers: request_headers
        )
        client.post(request).fmap do |response|
          ParseRateEstimateResponse.(response: response, request: request, carriers: carriers)
        end
      end

      def labels(shipment)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:labels],
          body: SerializeLabelShipment.new(shipment: shipment).call.merge(test_label: test).to_json,
          headers: request_headers
        )
        client.post(request).fmap do |response|
          ParseLabelResponse.(request: request, response: response)
        end
      end

      def void(label)
        request = FriendlyShipping::Request.new(
          url: "#{API_BASE}labels/#{label.id}/void",
          body: '',
          headers: request_headers
        )
        client.put(request).bind do |response|
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
