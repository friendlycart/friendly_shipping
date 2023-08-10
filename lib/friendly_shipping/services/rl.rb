# frozen_string_literal: true

require 'dry/monads'
require 'friendly_shipping/http_client'
require 'friendly_shipping/services/rl/bad_request_handler'
require 'friendly_shipping/services/rl/parse_create_bol_response'
require 'friendly_shipping/services/rl/parse_print_bol_response'
require 'friendly_shipping/services/rl/parse_print_shipping_labels_response'
require 'friendly_shipping/services/rl/parse_rate_quote_response'
require 'friendly_shipping/services/rl/parse_transit_times_response'
require 'friendly_shipping/services/rl/serialize_create_bol_request'
require 'friendly_shipping/services/rl/serialize_rate_quote_request'
require 'friendly_shipping/services/rl/serialize_transit_times_request'
require 'friendly_shipping/services/rl/rate_quote_options'
require 'friendly_shipping/services/rl/bol_options'
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
        print_bol: "BillOfLading/PrintBOL",
        print_shipping_labels: "BillOfLading/PrintShippingLabels",
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

      # Retrieve an existing binary BOL document for printing
      #
      # @param [String] pro_number The PRO number for the BOL to print
      #
      # @return [Dry::Monads::Result<ApiResult<ShippingDocument>>] The binary BOL document from R&L
      def print_bill_of_lading(pro_number, debug: false)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:print_bol] + "?ProNumber=#{pro_number}",
          http_method: "GET",
          headers: request_headers,
          debug: debug
        )
        client.get(request).bind do |response|
          ParsePrintBOLResponse.call(request: request, response: response)
        end
      end

      # Retrieve binary shipping labels for printing
      #
      # @param [String] pro_number The PRO number from the BOL for the shipping labels to print
      # @param [Integer] style The R&L shipping label style (between 1 and 13)
      # @see https://rl-cdn.com/docs/rlc/shipping-forms/shipping-label-select.pdf Shipping label styles
      # @param [Integer] start_position The R&L start position for the first label (between 1 and 10)
      # @param [Integer] num_labels Number of labels to print (between 1 and 100)
      # @return [Dry::Monads::Result<ApiResult<ShippingDocument>>] The binary shipping labels from R&L
      def print_shipping_labels(pro_number, style: 1, start_position: 1, num_labels: 4, debug: false)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:print_shipping_labels] + "?" \
            "ProNumber=#{pro_number}&" \
            "Style=#{style}&" \
            "StartPosition=#{start_position}&" \
            "NumberOfLabels=#{num_labels}",
          http_method: "GET",
          headers: request_headers,
          debug: debug
        )
        client.get(request).bind do |response|
          ParsePrintShippingLabelsResponse.call(request: request, response: response)
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
