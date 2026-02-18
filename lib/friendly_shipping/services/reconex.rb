# frozen_string_literal: true

require "json"

module FriendlyShipping
  module Services
    # API service class for Reconex, a freight management company.
    class Reconex
      include Dry::Monads::Result::Mixin

      # @return [String] the API key
      attr_reader :api_key

      # @return [String] the API base URL
      attr_reader :api_base_url

      # @return [HttpClient] the HTTP client to use for requests
      attr_reader :client

      # @return [Logger, nil] the logger for debug output
      attr_reader :logger

      # This carrier's API paths. Used when constructing endpoint URLs.
      API_PATHS = {
        get_quote: "/api/v1/IntegrationApi/GetQuote",
        create_load: "/api/v1/IntegrationApi/CreateLoad",
        update_load: "/api/v1/IntegrationApi/UpdateLoad",
        get_load_info: "/api/v1/IntegrationApi/GetLoadInfo",
        book_bestway_carrier: "/api/v1/IntegrationApi/BookBestwayCarrier"
      }.freeze

      # @param api_key [String] the API key
      # @param api_base_url [String] the API base URL
      # @param client [HttpClient] optional HTTP client to use for requests
      # @param logger [Logger, nil] optional logger for debug output
      def initialize(api_key:, api_base_url:, client: nil, logger: nil)
        @api_key = api_key
        @api_base_url = api_base_url
        @logger = logger

        error_handler = ApiErrorHandler.new(api_error_class: Reconex::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
      end

      # Get rate quotes for a shipment.
      #
      # @param shipment [Physical::Shipment] the shipment to quote
      # @param options [QuoteOptions] the quote options
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Success<ApiResult<Array<Rate>>>, Failure<ApiResult>]
      def rate_quote(shipment, options:, debug: false)
        request = FriendlyShipping::Request.new(
          url: api_base_url + API_PATHS[:get_quote],
          http_method: "POST",
          body: SerializeQuoteRequest.call(shipment: shipment, options: options).to_json,
          headers: request_headers,
          debug: debug
        )
        logger&.debug { "[Reconex] REQUEST: #{JSON.pretty_generate(JSON.parse(request.body))}" }
        client.post(request).bind do |response|
          logger&.debug { "[Reconex] RESPONSE: #{JSON.pretty_generate(JSON.parse(response.body))}" }
          ParseQuoteResponse.call(request: request, response: response)
        end
      end

      # Create a load (BOL) for a shipment.
      #
      # @param shipment [Physical::Shipment] the shipment to create a load for
      # @param options [LoadOptions] the load options
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Success<ApiResult<ShipmentInformation>>, Failure<ApiResult>]
      def create_load(shipment, options:, debug: false)
        request = FriendlyShipping::Request.new(
          url: api_base_url + API_PATHS[:create_load],
          http_method: "POST",
          body: SerializeCreateLoadRequest.call(shipment: shipment, options: options).to_json,
          headers: request_headers,
          debug: debug
        )
        logger&.debug { "[Reconex] REQUEST: #{JSON.pretty_generate(JSON.parse(request.body))}" }
        client.post(request).bind do |response|
          logger&.debug { "[Reconex] RESPONSE: #{JSON.pretty_generate(JSON.parse(response.body))}" }
          ParseCreateLoadResponse.call(request: request, response: response)
        end
      end

      # Get load information by ID, reference, or status.
      #
      # @param options [LoadInfoOptions] the load info options
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Success<ApiResult<Array<LoadInfo>>>, Failure<ApiResult>]
      def get_load_info(options:, debug: false)
        request = FriendlyShipping::Request.new(
          url: api_base_url + API_PATHS[:get_load_info],
          http_method: "POST",
          body: SerializeLoadInfoRequest.call(options: options).to_json,
          headers: request_headers,
          debug: debug
        )
        logger&.debug { "[Reconex] REQUEST: #{JSON.pretty_generate(JSON.parse(request.body))}" }
        client.post(request).bind do |response|
          logger&.debug { "[Reconex] RESPONSE: #{JSON.pretty_generate(JSON.parse(response.body))}" }
          ParseLoadInfoResponse.call(request: request, response: response)
        end
      end

      private

      # Returns the content type and API key as a headers hash.
      # @return [Hash]
      def request_headers
        {
          Content_Type: "application/json",
          Accept: "application/json",
          ApiKey: api_key
        }
      end
    end
  end
end
