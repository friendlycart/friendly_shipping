# frozen_string_literal: true

require 'dry/monads'
require 'friendly_shipping/http_client'
require 'friendly_shipping/services/rl/bad_request_handler'
require 'friendly_shipping/services/rl/parse_create_bol_response'
require 'friendly_shipping/services/rl/parse_rate_quote_response'
require 'friendly_shipping/services/rl/parse_transit_times_response'
require 'friendly_shipping/services/rl/serialize_create_bol_request'
require 'friendly_shipping/services/rl/serialize_rate_quote_request'
require 'friendly_shipping/services/rl/serialize_transit_times_request'
require 'friendly_shipping/services/rl/rate_quote_options'
require 'friendly_shipping/services/rl/bill_of_lading_options'
require 'friendly_shipping/services/rl/package_options'
require 'friendly_shipping/services/rl/item_options'

module FriendlyShipping
  module Services
    class RL
      include Dry::Monads::Result::Mixin

      attr_reader :api_key, :test, :client

      API_BASE = "https://api.rlc.com/"
      API_PATHS = {
        bill_of_lading: "BillOfLading",
        rate_quote: "RateQuote",
        transit_times: "TransitTimes"
      }.freeze

      # @param [String] api_key
      # @param [Boolean] test
      # @param [FriendlyShipping::HttpClient] client
      def initialize(
        api_key:,
        test: true,
        client: FriendlyShipping::HttpClient.new(
          error_handler: FriendlyShipping::Services::RL::BadRequestHandler
        )
      )
        @api_key = api_key
        @test = test
        @client = client
      end

      # Create an LTL BOL and schedule a pickup with R&L
      #
      # @param [Physical::Shipment] shipment The shipment for the BOL
      # @param [FriendlyShipping::Services::RL::QuoteOptions] options The options for the BOL
      #
      # @return [Dry::Monads::Result<ApiResult<PickupRequest>>] The BOL from R&L
      def create_bill_of_lading(shipment, options:, debug: false)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:bill_of_lading],
          http_method: "POST",
          body: SerializeCreateBOLRequest.call(shipment: shipment, options: options).to_json,
          headers: request_headers,
          debug: debug
        )
        client.post(request).bind do |response|
          ParseCreateBOLResponse.call(request: request, response: response)
        end
      end

      # Request an LTL rate quote from R&L
      #
      # @param [Physical::Shipment] shipment The shipment to quote
      # @param [FriendlyShipping::Services::RL::QuoteOptions] options The options for the quote
      #
      # @return [Dry::Monads::Result<ApiResult<Array<Rate>>>] The rate quote from R&L
      def rate_quote(shipment, options:, debug: false)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:rate_quote],
          http_method: "POST",
          body: SerializeRateQuoteRequest.call(shipment: shipment, options: options).to_json,
          headers: request_headers,
          debug: debug
        )
        client.post(request).bind do |response|
          ParseRateQuoteResponse.call(request: request, response: response)
        end
      end

      # Request an LTL transit timing from R&L
      #
      # @param [Physical::Shipment] shipment The shipment we're timing
      # @param [FriendlyShipping::Services::RL::QuoteOptions] options The options for the timing
      #
      # @return [Dry::Monads::Result<ApiResult<Array<Timing>>>] The transit timing from R&L
      def transit_times(shipment, options:, debug: false)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:transit_times],
          http_method: "POST",
          body: SerializeTransitTimesRequest.call(shipment: shipment, options: options).to_json,
          headers: request_headers,
          debug: debug
        )
        client.post(request).bind do |response|
          ParseTransitTimesResponse.call(request: request, response: response)
        end
      end

      private

      # @return [Hash]
      def request_headers
        {
          content_type: :json,
          apiKey: api_key
        }
      end
    end
  end
end
