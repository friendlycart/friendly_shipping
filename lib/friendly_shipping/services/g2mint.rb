# frozen_string_literal: true

require "json"

module FriendlyShipping
  module Services
    # API service class for G2Mint shipping integration.
    class G2Mint
      include Dry::Monads::Result::Mixin

      # @return [String] the API key for this carrier
      attr_reader :api_key

      # @return [Boolean] whether to use test API endpoints
      attr_reader :test

      # @return [HttpClient] the HTTP client to use for requests
      attr_reader :client

      # The G2Mint carrier
      CARRIER = FriendlyShipping::Carrier.new(
        id: "g2mint",
        name: "G2Mint",
        code: "g2mint",
        shipping_methods: SHIPPING_METHODS
      )

      # The API base URL for production.
      LIVE_API_BASE = "https://api.g2mint.com"

      # The API base URL for testing.
      TEST_API_BASE = "https://sdg-api.g2mint.com"

      # This carrier's API paths. Used when constructing endpoint URLs.
      RESOURCES = {
        rates: "/rateapi/rates"
      }.freeze

      # @param api_key [String] the API key for this carrier
      # @param test [Boolean] whether to use test API endpoints
      # @param client [HttpClient] optional HTTP client to use for requests
      def initialize(api_key:, test: true, client: nil)
        @api_key = api_key
        @test = test

        error_handler = ApiErrorHandler.new(api_error_class: G2Mint::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
      end

      # @return [Success<Array<Carrier>>]
      def carriers
        Success([CARRIER])
      end

      # Get rates for a shipment
      # @see https://developers.g2mint.com/#tag/Rating/paths/~1rates/post API documentation
      #
      # @param shipment [Physical::Shipment] the shipment to get rates for
      # @param options [REST::RatesOptions] options for obtaining rates for this shipment
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Result<ApiResult<Array<Rate>>>] the rates from G2Mint
      def rates(shipment, options:, debug: false)
        request_hash = REST::GenerateRatesRequestHash.call(shipment: shipment, options: options)
        request = build_request(:rates, request_hash, debug)

        client.post(request).fmap do |response|
          REST::ParseRatesResponse.call(response: response, request: request)
        end
      end

      private

      # Returns the API base URL based on the {test} attribute's value.
      # @return [String]
      def api_base
        test ? TEST_API_BASE : LIVE_API_BASE
      end

      # Builds a request object with appropriate headers for G2Mint API.
      # @param action [Symbol] the action/endpoint key from RESOURCES
      # @param payload [Hash] the request body to be JSON-encoded
      # @param debug [Boolean] whether to include debug information
      # @return [Request]
      def build_request(action, payload, debug)
        FriendlyShipping::Request.new(
          url: api_base + RESOURCES[action],
          http_method: "POST",
          body: payload.to_json,
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Key #{api_key}"
          },
          debug:
        )
      end
    end
  end
end
