# frozen_string_literal: true

require "json"

module FriendlyShipping
  module Services
    # API service class for Reconex, a freight management company.
    class Reconex
      include Dry::Monads::Result::Mixin

      # @return [String] the API key
      attr_reader :api_key

      # @return [Boolean] whether to use test API endpoints
      attr_reader :test

      # @return [String] the API base URL for live/production requests
      attr_reader :live_api_base

      # @return [String] the API base URL for test requests
      attr_reader :test_api_base

      # @return [HttpClient] the HTTP client to use for requests
      attr_reader :client

      # This carrier's API paths. Used when constructing endpoint URLs.
      API_PATHS = {
        get_quote: "/api/v1/IntegrationApi/GetQuote",
        create_load: "/api/v1/IntegrationApi/CreateLoad",
        update_load: "/api/v1/IntegrationApi/UpdateLoad",
        get_load_info: "/api/v1/IntegrationApi/GetLoadInfo",
        book_bestway_carrier: "/api/v1/IntegrationApi/BookBestwayCarrier"
      }.freeze

      # @param api_key [String] the API key
      # @param live_api_base [String] the API base URL for live/production requests
      # @param test_api_base [String] the API base URL for test requests
      # @param test [Boolean] whether to use test API endpoints
      # @param client [HttpClient] optional HTTP client to use for requests
      def initialize(api_key:, live_api_base:, test_api_base:, test: true, client: nil)
        @api_key = api_key
        @live_api_base = live_api_base
        @test_api_base = test_api_base
        @test = test

        error_handler = ApiErrorHandler.new(api_error_class: Reconex::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
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

      # Returns the API base URL based on the {test} attribute's value.
      # @return [String]
      def api_base
        test ? test_api_base : live_api_base
      end
    end
  end
end
