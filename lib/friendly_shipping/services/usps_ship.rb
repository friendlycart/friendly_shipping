# frozen_string_literal: true

require 'friendly_shipping/http_client'

require 'friendly_shipping/services/usps_ship/access_token'
require 'friendly_shipping/services/usps_ship/api_error'
require 'friendly_shipping/services/usps_ship/shipping_methods'

require 'friendly_shipping/services/usps_ship/rate_estimate_options'

require 'friendly_shipping/services/usps_ship/serialize_rate_estimates_request'

require 'friendly_shipping/services/usps_ship/parse_rate_estimates_response'

module FriendlyShipping
  module Services
    class USPSShip
      include Dry::Monads::Result::Mixin

      # @return [AccessToken] the access token
      attr_reader :access_token

      # @return [Boolean] whether to use the test API version
      attr_reader :test

      # @return [HttpClient] the HTTP client
      attr_reader :client

      # The USPS carrier
      CARRIER = FriendlyShipping::Carrier.new(
        id: 'usps',
        name: 'United States Postal Service',
        code: 'usps',
        shipping_methods: SHIPPING_METHODS
      )

      # The base URL for USPS Ship requests
      BASE_URL = 'https://api.usps.com'

      # The USPS Ship API endpoints
      RESOURCES = {
        token: 'oauth2/v3/token',
        rates: 'prices/v3/base-rates/search'
      }.freeze

      # @param access_token [AccessToken] the access token
      # @param test [Boolean] whether to use the test API version
      # @param client [HttpClient] optional HTTP client to use for requests
      def initialize(access_token:, test: true, client: nil)
        @access_token = access_token
        @test = test
        error_handler = ApiErrorHandler.new(api_error_class: USPSShip::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
      end

      # @return [Array<Carrier>]
      def carriers
        Success([CARRIER])
      end

      # Creates an access token that can be used for future API requests.
      # @see https://developer.usps.com/api/81 OAuth 2.0 docs
      #
      # @param client_id [String] the Client ID of your application from the OAuth Client dialog
      # @param client_secret [String] the secret you created in the OAuth Client Secrets section of the OAuth Client dialog
      # @param grant_type [String] defaults to "client_credentials" to indicate you wish to obtain a token representing your confidential client application
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [ApiResult<AccessToken>] the {AccessToken} wrapped in an {ApiResult} object
      def create_access_token(
        client_id:,
        client_secret:,
        grant_type: "client_credentials",
        debug: false
      )
        request = FriendlyShipping::Request.new(
          url: "#{BASE_URL}/#{RESOURCES[:token]}",
          http_method: "POST",
          body: "client_id=#{client_id}&" \
                "client_secret=#{client_secret}&" \
                "grant_type=#{grant_type}",
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
              raw_token: hash['access_token']
            ),
            original_request: request,
            original_response: response
          )
        end
      end

      # Get rate estimates.
      # @see https://developer.usps.com/api/73#tag/Resources/operation/post-base-rates-search API documentation
      #
      # @param shipment [Physical::Shipment] the shipment for which we want to get rates
      # @param options [RateEstimateOptions] options for obtaining rates for this shipment
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Result<ApiResult<Array<Rate>>>] the {Rate}s wrapped in an {ApiResult} object
      def rate_estimates(shipment, options:, debug: false)
        rate_request = SerializeRateEstimatesRequest.call(shipment: shipment, options: options)
        request = build_request(api: :rates, payload: rate_request, debug: debug)

        client.post(request).bind do |response|
          ParseRateEstimatesResponse.call(response: response, request: request)
        end
      end

      private

      # @param api [Symbol]
      # @param payload [Hash]
      # @param debug [Boolean]
      # @return [Request]
      def build_request(api:, payload:, debug:)
        FriendlyShipping::Request.new(
          url: "#{BASE_URL}/#{RESOURCES[api]}",
          http_method: "POST",
          body: payload.to_json,
          debug: debug,
          headers: {
            Content_Type: "application/json",
            Accept: "application/json",
            Authorization: "Bearer #{access_token.raw_token}"
          }
        )
      end
    end
  end
end
