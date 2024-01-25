# frozen_string_literal: true

require 'dry/monads'
require 'friendly_shipping/http_client'
require 'friendly_shipping/services/ups_json/access_token'
require 'friendly_shipping/services/ups_json/api_error'
require 'friendly_shipping/services/ups_json/generate_rates_payload'
require 'friendly_shipping/services/ups_json/parse_json_response'
require 'friendly_shipping/services/ups_json/parse_money_hash'
require 'friendly_shipping/services/ups_json/parse_rate_modifier_hash'
require 'friendly_shipping/services/ups_json/parse_rates_response'
require 'friendly_shipping/services/ups_json/rates_item_options'
require 'friendly_shipping/services/ups_json/rates_package_options'
require 'friendly_shipping/services/ups_json/rates_options'
require 'friendly_shipping/services/ups_json/shipping_methods'

module FriendlyShipping
  module Services
    class UpsJson
      include Dry::Monads[:result]

      attr_reader :access_token, :test, :client

      SHIPPING_METHODS = FriendlyShipping::Services::UpsJson::SHIPPING_METHODS
      CARRIER = FriendlyShipping::Carrier.new(
        id: 'ups',
        name: 'United Parcel Service',
        code: 'ups',
        shipping_methods: SHIPPING_METHODS
      )

      TEST_URL = 'https://wwwcie.ups.com'
      LIVE_URL = 'https://onlinetools.ups.com'

      def initialize(access_token:, test: true, client: nil)
        @access_token = access_token
        @test = test
        error_handler = ApiErrorHandler.new(api_error_class: UpsJson::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
      end

      def carriers
        Success([CARRIER])
      end

      # Creates an access token to be used for future API requests.
      #
      # @param client_id [String] the Client ID of your UPS application
      # @param client_secret [String] the Client Secret of your UPS application
      # @param merchant_id [String] the shipper number associated with your UPS application
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [ApiResult<AccessToken>] the access token
      def create_access_token(
        client_id:,
        client_secret:,
        merchant_id:,
        debug: false
      )
        request = FriendlyShipping::Request.new(
          url: "#{base_url}/security/v1/oauth/token",
          http_method: "POST",
          body: "grant_type=client_credentials",
          headers: {
            Authorization: "Basic #{Base64.urlsafe_encode64("#{client_id}:#{client_secret}")}",
            Content_Type: "application/x-www-form-urlencoded",
            'X-Merchant-Id': merchant_id,
            Accept: "application/json"
          },
          debug: debug
        )
        client.post(request).fmap do |response|
          hash = JSON.parse(response.body)
          FriendlyShipping::ApiResult.new(
            AccessToken.new(
              expires_in: hash['expires_in'],
              issued_at: hash['issued_at'],
              raw_token: hash['access_token']
            ),
            original_request: request,
            original_response: response
          )
        end
      end

      # Get rates for a shipment
      # @param [Physical::Shipment] shipment The shipment we want to get rates for
      # @param [FriendlyShipping::Services::UpsJson::RateOptions] options What options
      #    to use for this rate request
      # @return [Result<ApiResult<Array<Rate>>>] The rates returned from UPS encoded in a
      #   `FriendlyShipping::ApiResult` object.
      def rates(shipment, options:, debug: false)
        # maybe add v outside of sub_version since ups is inconsistent?
        url = "#{base_url}/api/rating/#{options.sub_version || 'v1'}/Shop"
        headers = {
          "Authorization" => "Bearer #{access_token}",
          "Content-Type" => "application/json",
          "Accept" => "application/json"
        }.compact
        rates_request_body = GenerateRatesPayload.call(shipment: shipment, options: options).to_json

        request = FriendlyShipping::Request.new(
          url:,
          http_method: "POST",
          headers:,
          body: rates_request_body,
          debug:
        )

        client.post(request).bind do |response|
          ParseRatesResponse.call(response: response, request: request, shipment: shipment)
        end
      end
      alias_method :rate_estimates, :rates

      # Get timing information for a shipment
      # @param [Physical::Shipment] shipment The shipment we want to estimate timings for
      # @param [FriendlyShipping::Services::Ups::TimingOptions] options Options for this call
      def timings(shipment, options:, debug: false)
        raise 'NYI'

        time_in_transit_request_xml = SerializeTimeInTransitRequest.call(
          shipment: shipment,
          options: options
        )
        time_in_transit_url = base_url + RESOURCES[:timings]

        request = FriendlyShipping::Request.new(
          url: time_in_transit_url,
          http_method: "POST",
          body: access_request_xml + time_in_transit_request_xml,
          readable_body: time_in_transit_request_xml,
          debug: debug
        )

        client.post(request).bind do |response|
          ParseTimeInTransitResponse.call(response: response, request: request)
        end
      end

      def labels(shipment, options:, debug: false)
        ## Method body starts
        ship_confirm_request_xml = SerializeShipmentConfirmRequest.call(
          shipment: shipment,
          options: options
        )
        ship_confirm_url = base_url + RESOURCES[:ship_confirm]

        ship_confirm_request = FriendlyShipping::Request.new(
          url: ship_confirm_url,
          http_method: "POST",
          body: access_request_xml + ship_confirm_request_xml,
          readable_body: ship_confirm_request_xml,
          debug: debug
        )

        client.post(ship_confirm_request).bind do |ship_confirm_response|
          ParseShipmentConfirmResponse.call(
            request: ship_confirm_request,
            response: ship_confirm_response
          )
        end.bind do |ship_confirm_result|
          ship_accept_url = base_url + RESOURCES[:ship_accept]
          ship_accept_request_xml = SerializeShipmentAcceptRequest.call(
            digest: ship_confirm_result.data,
            options: options
          )

          ship_accept_request = FriendlyShipping::Request.new(
            url: ship_accept_url,
            http_method: "POST",
            body: access_request_xml + ship_accept_request_xml,
            readable_body: ship_accept_request_xml,
            debug: debug
          )

          client.post(ship_accept_request).bind do |ship_accept_response|
            ParseShipmentAcceptResponse.call(request: ship_accept_request, response: ship_accept_response)
          end
        end
      end

      # Classify an address.
      # @param [Physical::Location] location The address we want to classify
      # @return [Result<ApiResult<String>>] Either `"commercial"`, `"residential"`, or `"unknown"`
      def address_classification(location, debug: false)
        address_validation_request_xml = SerializeAddressValidationRequest.call(location: location)
        url = base_url + RESOURCES[:address_validation]
        request = FriendlyShipping::Request.new(
          url: url,
          http_method: "POST",
          body: access_request_xml + address_validation_request_xml,
          readable_body: address_validation_request_xml,
          debug: debug
        )

        client.post(request).bind do |response|
          ParseAddressClassificationResponse.call(response: response, request: request)
        end
      end

      def void(label, debug: false)
        url = base_url + RESOURCES[:void]
        void_request_xml = SerializeVoidShipmentRequest.call(label: label)
        request = FriendlyShipping::Request.new(
          url: url,
          http_method: "POST",
          body: access_request_xml + void_request_xml,
          readable_body: void_request_xml,
          debug: debug
        )
        client.post(request).bind do |response|
          ParseVoidShipmentResponse.call(request: request, response: response)
        end
      end

      private

      def base_url
        test ? TEST_URL : LIVE_URL
      end
    end
  end
end
