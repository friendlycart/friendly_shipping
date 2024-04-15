# frozen_string_literal: true

require 'friendly_shipping/http_client'

require 'friendly_shipping/services/usps_ship/access_token'
require 'friendly_shipping/services/usps_ship/api_error'
require 'friendly_shipping/services/usps_ship/shipping_methods'

require 'friendly_shipping/services/usps_ship/rate_estimate_options'
require 'friendly_shipping/services/usps_ship/rate_estimate_package_options'
require 'friendly_shipping/services/usps_ship/timing_options'

require 'friendly_shipping/services/usps_ship/serialize_rate_estimates_request'
require 'friendly_shipping/services/usps_ship/machinable_package'

require 'friendly_shipping/services/usps_ship/parse_rate_estimates_response'
require 'friendly_shipping/services/usps_ship/parse_timings_response'

module FriendlyShipping
  module Services
    class USPSShip
      include Dry::Monads::Result::Mixin
      include Dry::Monads::Do.for(:rate_estimates)

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
        rates: 'prices/v3/base-rates/search',
        timings: 'service-standards/v3/estimates'
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
      # NOTE: Since USPS Ship does not support returning multiple rates at the same time, we have to
      # make multiple API calls for shipments with more than one package and sum the results.
      #
      # @param shipment [Physical::Shipment] the shipment for which we want to get rates
      # @param options [RateEstimateOptions] options for obtaining rates for this shipment
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Result<ApiResult<Array<Rate>>>] the {Rate}s wrapped in an {ApiResult} object
      def rate_estimates(shipment, options:, debug: false)
        rates = shipment.packages.map do |package|
          yield begin
            rate_request = SerializeRateEstimatesRequest.call(shipment: shipment, package: package, options: options)
            request = build_request(api: :rates, payload: rate_request, debug: debug)

            client.post(request).bind do |response|
              ParseRateEstimatesResponse.call(response: response, request: request)
            end
          end
        end.flat_map(&:data)

        amounts = rates.each_with_object({}) do |rate, result|
          rate.amounts.each do |name, amount|
            result[name] ||= 0
            result[name] += amount
          end
        end

        Success(
          ApiResult.new(
            [
              FriendlyShipping::Rate.new(
                amounts: amounts,
                shipping_method: rates.first.shipping_method,
                data: rates.first.data
              )
            ]
          )
        )
      end

      # Get timing estimates.
      # @see https://developer.usps.com/api/85#tag/Resources/operation/get-estimates API documentation
      #
      # @param shipment [Physical::Shipment] the shipment for which we want to get timings
      # @param options [TimingOptions] options for the timing estimate call
      # @return [Result<ApiResult<Array<Timing>>>] the {Timing}s wrapped in an {ApiResult} object
      def timings(shipment, options:, debug: false)
        request = FriendlyShipping::Request.new(
          url: "#{BASE_URL}/#{RESOURCES[:timings]}?" \
               "originZIPCode=#{shipment.origin.zip}&" \
               "destinationZIPCode=#{shipment.destination.zip}&" \
               "mailClass=#{options.shipping_method.service_code}&" \
               "acceptanceDate=#{options.mailing_date.strftime('%Y-%m-%d')}",
          http_method: "GET",
          debug: debug,
          headers: {
            Accept: "application/json",
            Authorization: "Bearer #{access_token.raw_token}"
          }
        )

        client.get(request).bind do |response|
          ParseTimingsResponse.call(response: response, request: request)
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
