# frozen_string_literal: true

require "json"

module FriendlyShipping
  module Services
    # API service class for ShipEngine LTL, a shipping API supporting Freight carriers.
    # @see https://www.shipengine.com/docs/ltl/ ShipEngine LTL API docs
    class ShipEngineLTL
      include Dry::Monads::Result::Mixin

      # The API base URL.
      API_BASE = "https://api.shipengine.com/v-beta/ltl/"

      # The API paths. Used when constructing endpoint URLs.
      API_PATHS = {
        connections: "connections",
        carriers: "carriers",
        quotes: "quotes"
      }.freeze

      # @param token [String] the API token
      # @param test [Boolean] whether to use test API endpoints
      # @param client [HttpClient] optional custom HTTP client to use for requests
      def initialize(token:, test: true, client: nil)
        @token = token
        @test = test

        error_handler = ApiErrorHandler.new(api_error_class: ShipEngineLTL::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
      end

      # Get configured LTL carriers.
      #
      # @param debug [Boolean] whether to attach debugging information to the response
      # @return [Success<ApiResult<Array<Carrier>>>, Failure<ApiResult<Array<String>>>] On success,
      #   LTL carriers configured in your account. On failure, a list of error messages.
      def carriers(debug: false)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:carriers],
          headers: request_headers,
          debug: debug
        )
        client.get(request).bind do |response|
          ParseCarrierResponse.call(request: request, response: response)
        end
      end

      # Connect an LTL carrier.
      #
      # @param credentials [Hash] the carrier's connection information
      # @param scac [String] Standard Carrier Alpha Code
      # @see https://nmfta.org/scac/ SCAC
      # @param debug [Boolean] whether to attach debugging information to the response
      # @return [Success<ApiResult<Hash>>, Failure<ApiResult<String>>] the carrier or error message
      def connect_carrier(credentials, scac, debug: false)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:connections] + "/#{scac}",
          body: { credentials: credentials }.to_json,
          headers: request_headers,
          debug: debug
        )
        client.post(request).bind do |response|
          Success(
            ApiResult.new(
              JSON.parse(response.body),
              original_request: request,
              original_response: response
            )
          )
        end
      end

      # Update an existing LTL carrier.
      #
      # @param credentials [Hash] the carrier's connection information
      # @param scac [String] Standard Carrier Alpha Code
      # @see https://nmfta.org/scac/ SCAC
      # @param carrier_id [String] the ID for the carrier you want to update
      # @param debug [Boolean] whether to attach debugging information to the response
      # @return [Success<ApiResult<Hash>>, Failure<ApiResult<String>>] the carrier or error message
      def update_carrier(credentials, scac, carrier_id, debug: false)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:connections] + "/#{scac}/#{carrier_id}",
          body: { credentials: credentials }.to_json,
          headers: request_headers,
          debug: debug
        )
        client.put(request).bind do |response|
          Success(
            ApiResult.new(
              JSON.parse(response.body),
              original_request: request,
              original_response: response
            )
          )
        end
      end

      # Request an LTL price quote.
      #
      # @param carrier_id [String] the carrier ID
      # @param shipment [Physical::Shipment] the shipment to quote
      # @param options [QuoteOptions] the options for the quote
      # @param debug [Boolean] whether to attach debugging information to the response
      # @return [Success<ApiResult<Hash>>, Failure<ApiResult<String>>] the quote or error message
      def request_quote(carrier_id, shipment, options, debug: false)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:quotes] + "/#{carrier_id}",
          http_method: "POST",
          body: SerializeQuoteRequest.call(shipment: shipment, options: options).to_json,
          headers: request_headers,
          debug: debug
        )
        client.post(request).bind do |response|
          ParseQuoteResponse.call(request: request, response: response)
        end
      end

      private

      # @return [String] the API token
      attr_reader :token

      # @return [Boolean] whether to use test API endpoints
      attr_reader :test

      # @return [HttpClient] the HTTP client to use for requests
      attr_reader :client

      # Returns the content type and API key as a headers hash.
      # @return [Hash]
      def request_headers
        {
          content_type: :json,
          'api-key': token
        }
      end
    end
  end
end
