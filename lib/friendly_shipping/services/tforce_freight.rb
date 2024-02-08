# frozen_string_literal: true

require 'dry/monads'
require 'friendly_shipping/http_client'
require 'friendly_shipping/services/tforce_freight/access_token'
require 'friendly_shipping/services/tforce_freight/shipping_methods'
require 'friendly_shipping/services/tforce_freight/shipment_document'
require 'friendly_shipping/services/tforce_freight/rates_options'
require 'friendly_shipping/services/tforce_freight/rates_package_options'
require 'friendly_shipping/services/tforce_freight/rates_item_options'
require 'friendly_shipping/services/tforce_freight/pickup_options'
require 'friendly_shipping/services/tforce_freight/bol_options'
require 'friendly_shipping/services/tforce_freight/document_options'
require 'friendly_shipping/services/tforce_freight/parse_rates_response'
require 'friendly_shipping/services/tforce_freight/parse_pickup_response'
require 'friendly_shipping/services/tforce_freight/parse_create_bol_response'
require 'friendly_shipping/services/tforce_freight/parse_shipment_document'
require 'friendly_shipping/services/tforce_freight/generate_rates_request_hash'
require 'friendly_shipping/services/tforce_freight/generate_pickup_request_hash'
require 'friendly_shipping/services/tforce_freight/generate_create_bol_request_hash'
require 'friendly_shipping/services/tforce_freight/generate_handling_units_hash'
require 'friendly_shipping/services/tforce_freight/generate_reference_hash'
require 'friendly_shipping/services/tforce_freight/generate_document_options_hash'
require 'friendly_shipping/services/tforce_freight/api_error'

module FriendlyShipping
  module Services
    class TForceFreight
      include Dry::Monads[:result]

      # @return [AccessToken] the access token
      attr_reader :access_token

      # @return [Boolean] whether to use the test API version
      attr_reader :test

      # @return [HttpClient] the HTTP client
      attr_reader :client

      # The TForce Freight carrier
      CARRIER = FriendlyShipping::Carrier.new(
        id: 'tforce_freight',
        name: 'TForce Freight',
        code: 'tforce_freight-freight',
        shipping_methods: SHIPPING_METHODS
      )

      # The base URL for TForce API requests
      BASE_URL = 'https://api.tforcefreight.com'

      # The TForce API endpoints
      RESOURCES = {
        rates: '/rating/getRate',
        create_pickup: '/pickup/request',
        create_bol: '/shipping/bol/create'
      }.freeze

      # @param access_token [AccessToken] the access token
      # @param test [Boolean] whether to use the test API version
      # @param client [HttpClient] optional HTTP client to use for requests
      def initialize(access_token:, test: true, client: nil)
        @access_token = access_token
        @test = test

        error_handler = ApiErrorHandler.new(api_error_class: TForceFreight::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
      end

      # @return [Array<Carrier>]
      def carriers
        Success([CARRIER])
      end

      # Creates an access token that can be used for future API requests.
      # @see https://developer.tforcefreight.com/resources/integration-end-user End User Integration Guide
      #
      # @param token_endpoint [String] the Token Endpoint from the Application Integration section of your OAuth Client dialog
      # @param client_id [String] the Client ID of your application from the OAuth Client dialog
      # @param client_secret [String] the secret you created in the OAuth Client Secrets section of the OAuth Client dialog
      # @param scope [String] the Scope value from the Application Integration section your OAuth Client dialog
      # @param grant_type [String] defaults to "client_credentials" to indicate you wish to obtain a token representing your confidential client application
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [ApiResult<AccessToken>] the access token
      def create_access_token(
        token_endpoint:,
        client_id:,
        client_secret:,
        scope:,
        grant_type: "client_credentials",
        debug: false
      )
        request = FriendlyShipping::Request.new(
          url: token_endpoint,
          http_method: "POST",
          body: "client_id=#{client_id}&" \
                "client_secret=#{client_secret}&" \
                "grant_type=#{grant_type}&" \
                "scope=#{scope}",
          headers: {
            Content_Type: "application/x-www-form-urlencoded",
            Accept: "application/json"
          },
          debug: debug
        )
        client.post(request).fmap do |response|
          hash = JSON.parse(response.body)
          FriendlyShipping::ApiResult.new(
            AccessToken.new(
              token_type: hash['token_type'],
              expires_in: hash['expires_in'],
              ext_expires_in: hash['ext_expires_in'],
              raw_token: hash['access_token']
            ),
            original_request: request,
            original_response: response
          )
        end
      end

      # Get rates for a shipment
      # @see https://developer.tforcefreight.com/api-details#api=rating-v1&operation=get-rate API documentation
      #
      # @param shipment [Physical::Shipment] the shipment for which we want to get rates
      # @param options [RatesOptions] options for obtaining rates for this shipment
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Result<ApiResult<Array<Rate>>>] the rates returned from TForce encoded in a `ApiResult` object
      def rates(shipment, options:, debug: false)
        freight_rate_request_hash = GenerateRatesRequestHash.call(shipment: shipment, options: options)
        request = build_request(:rates, freight_rate_request_hash, debug)

        client.post(request).fmap do |response|
          ParseRatesResponse.call(response: response, request: request)
        end
      end

      # Create a pickup request
      # @see https://developer.tforcefreight.com/api-details#api=pickup-v1&operation=create-request API documentation
      #
      # @param shipment [Physical::Shipment] the shipment for which to create a pickup request
      # @param options [PickupOptions] options for the pickup request
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Result<ApiResult>] the pickup returned from TForce encoded in a `ApiResult` object
      def create_pickup(shipment, options:, debug: false)
        pickup_request_hash = GeneratePickupRequestHash.call(shipment: shipment, options: options)
        request = build_request(:create_pickup, pickup_request_hash, debug)

        client.post(request).fmap do |response|
          ParsePickupResponse.call(response: response, request: request)
        end
      end

      # Create a Bill of Lading (BOL)
      # @see https://developer.tforcefreight.com/api-details#api=shipping-cie-vnext&operation=shipping-create-bol API documentation
      #
      # @param shipment [Physical::Shipment] the shipment for which to create a BOL
      # @param options [PickupOptions] options for the BOL
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Result<ApiResult>] the BOL returned from TForce encoded in a `ApiResult` object
      def create_bol(shipment, options:, debug: false)
        bol_request_hash = GenerateCreateBOLRequestHash.call(shipment: shipment, options: options)
        request = build_request(:create_bol, bol_request_hash, debug)

        client.post(request).fmap do |response|
          ParseCreateBOLResponse.call(response: response, request: request)
        end
      end

      alias_method :rate_estimates, :rates

      private

      # @param action [Symbol] the desired action key from {RESOURCES}
      # @param payload [Hash] the payload to send to the API
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Request]
      def build_request(action, payload, debug)
        url = BASE_URL + RESOURCES[action] + "?api-version=#{api_version}"
        FriendlyShipping::Request.new(
          url: url,
          http_method: "POST",
          body: payload.to_json,
          headers: {
            Content_Type: "application/json",
            Accept: "application/json",
            Authorization: "Bearer #{access_token.raw_token}"
          },
          debug: debug
        )
      end

      # @return [String] the API version to use
      def api_version
        test ? "cie-v1" : "v1"
      end
    end
  end
end
