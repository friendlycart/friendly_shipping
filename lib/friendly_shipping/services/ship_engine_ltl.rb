# frozen_string_literal: true

require 'dry/monads/result'
require 'friendly_shipping/http_client'
require 'friendly_shipping/services/ship_engine/bad_request_handler'
require 'friendly_shipping/services/ship_engine_ltl/parse_carrier_response'

module FriendlyShipping
  module Services
    class ShipEngineLTL
      include Dry::Monads::Result::Mixin

      API_BASE = "https://api.shipengine.com/v-beta/ltl/"
      API_PATHS = {
        connections: "connections",
        carriers: "carriers"
      }.freeze

      def initialize(token:, test: true, client: FriendlyShipping::HttpClient.new(error_handler: FriendlyShipping::Services::ShipEngine::BadRequestHandler))
        @token = token
        @test = test
        @client = client
      end

      # Get configured LTL carriers from ShipEngine
      #
      # @return [Result<ApiResult<Array<Carrier>>>] LTL carriers configured in your account
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

      # Connect an LTL carrier to ShipEngine
      #
      # @param [Hash] credentials The carrier's connection information
      # @param [String] scac Standard Carrier Alpha Code
      #
      # @return [Result<ApiResult<Hash>>] The unique carrier ID assigned by ShipEngine
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

      # Update an existing LTL carrier in ShipEngine
      #
      # @param [Hash] credentials The carrier's connection information
      # @param [String] scac Standard Carrier Alpha Code
      # @param [String] carrier_id The carrier ID from ShipEngine that you want to update
      #
      # @return [Result<ApiResult<Hash>>] The unique carrier ID assigned by ShipEngine
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
