# frozen_string_literal: true

require 'dry/monads/result'
require 'friendly_shipping/http_client'
require 'friendly_shipping/services/ship_engine/bad_request_handler'
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
      }.freeze

      def initialize(token:, test: true, client: FriendlyShipping::HttpClient.new(error_handler: BadRequestHandler))
        @token = token
        @test = test
        @client = client
      end

      # Get configured carriers from USPS
      #
      # @return [Result<ApiResult<Array<Carrier>>>] Carriers configured in your shipstation account
      def carriers
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:carriers],
          headers: request_headers
        )
        client.get(request).fmap do |response|
          ParseCarrierResponse.call(request: request, response: response)
        end
      end

      # Get rate estimates from ShipEngine
      #
      # @param [Physical::Shipment] shipment The shipment object we're trying to get results for
      #
      # @options[:carriers] [Physical::Carrier] The carriers we want to get rates from. What counts
      # here is the carrier code, so by specifying them upfront you can save a request.
      #
      # @return [Result<ApiResult<Array<FriendlyShipping::Rate>>>] When successfully parsing, an array of rates in a Success Monad.
      #   When the parsing is not successful or ShipEngine can't give us rates, a Failure monad containing something that
      #   can be serialized into an error message using `to_s`.
      def rate_estimates(shipment, selected_carriers: nil)
        selected_carriers ||= carriers.value!.data
        request = FriendlyShipping::Request.new(
          url: API_BASE + 'rates/estimate',
          body: SerializeRateEstimateRequest.call(shipment: shipment, carriers: selected_carriers).to_json,
          headers: request_headers
        )
        client.post(request).bind do |response|
          ParseRateEstimateResponse.call(response: response, request: request, carriers: selected_carriers)
        end
      end

      # Get label(s) from ShipEngine
      #
      # @param [Physical::Shipment] shipment The shipment object we're trying to get labels for
      #   Note: Some ShipEngine carriers, notably USPS, only support one package per shipment, and that's
      #   all that the integration supports at this point.
      #
      # @return [Result<ApiResult<Array<FriendlyShipping::Label>>>] The label returned.
      #
      def labels(shipment)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:labels],
          body: SerializeLabelShipment.new(shipment: shipment).call.merge(test_label: test).to_json,
          headers: request_headers
        )
        client.post(request).fmap do |response|
          ParseLabelResponse.call(request: request, response: response)
        end
      end

      def void(label)
        request = FriendlyShipping::Request.new(
          url: "#{API_BASE}labels/#{label.id}/void",
          body: '',
          headers: request_headers
        )
        client.put(request).bind do |response|
          ParseVoidResponse.call(request: request, response: response)
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
