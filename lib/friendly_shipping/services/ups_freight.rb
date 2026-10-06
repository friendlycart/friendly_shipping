# frozen_string_literal: true

require "json"

module FriendlyShipping
  module Services
    # Service class for the UPS Freight (LTL) API. Provides rate estimates and labels (bills of lading).
    class UpsFreight
      include Dry::Monads::Result::Mixin

      # @return [Boolean] whether requests are sent to the test (CIE) environment
      attr_reader :test

      # @return [String] the access license number sent in the AccessLicenseNumber header
      attr_reader :key

      # @return [String] the username sent in the Username header
      attr_reader :login

      # @return [String] the password sent in the Password header
      attr_reader :password

      # @return [#post] the HTTP client used to send requests
      attr_reader :client

      # The carrier object returned by {#carriers}.
      CARRIER = FriendlyShipping::Carrier.new(
        id: 'ups_freight',
        name: 'United Parcel Service LTL',
        code: 'ups-freight',
        shipping_methods: SHIPPING_METHODS
      )

      # Base URL used when `test` is true.
      TEST_URL = 'https://wwwcie.ups.com'
      # Base URL used when `test` is false.
      LIVE_URL = 'https://onlinetools.ups.com'

      # Maps request types to API resource paths.
      RESOURCES = {
        rates: '/ship/v1801/freight/rating/ground',
        labels: '/ship/v1607/freight/shipments/Ground'
      }.freeze

      # @param key [String] the access license number
      # @param login [String] the UPS username
      # @param password [String] the UPS password
      # @param test [Boolean] whether to use the test environment instead of the live one
      # @param client [#post, nil] an HTTP client to use instead of the default {HttpClient}
      def initialize(key:, login:, password:, test: true, client: nil)
        @key = key
        @login = login
        @password = password
        @test = test

        error_handler = ApiErrorHandler.new(api_error_class: UpsFreight::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
      end

      # Returns the carriers supported by this service.
      # @return [Result<Array<Carrier>>] a Success containing {CARRIER}
      def carriers
        Success([CARRIER])
      end

      # Get rates for a shipment
      # @param shipment [Physical::Shipment] The shipment we want to get rates for
      # @param options [RatesOptions] Options for obtaining rates for this shipment.
      # @param debug [Boolean] whether to include debug information in the request
      # @return [Result<ApiResult<Array<Rate>>>] The rates returned from UPS encoded in a
      #   `FriendlyShipping::ApiResult` object.
      def rate_estimates(shipment, options:, debug: false)
        freight_rate_request_hash = GenerateFreightRateRequestHash.call(shipment: shipment, options: options)
        request = build_request(:rates, freight_rate_request_hash, debug)

        client.post(request).fmap do |response|
          ParseFreightRateResponse.call(response: response, request: request)
        end
      end

      # Get labels for a shipment
      # @param shipment [Physical::Shipment] The shipment we want to get labels for
      # @param options [LabelOptions] Options for shipping this shipment.
      # @param debug [Boolean] whether to include debug information in the request
      # @return [Result<ApiResult<ShipmentInformation>>] The information that you need for shipping this shipment.
      def labels(shipment, options:, debug: false)
        freight_ship_request_hash = GenerateFreightShipRequestHash.call(shipment: shipment, options: options)
        request = build_request(:labels, freight_ship_request_hash, debug)

        client.post(request).fmap do |response|
          ParseFreightLabelResponse.call(response: response, request: request)
        end
      end

      private

      # @param action [Symbol] a key of {RESOURCES}
      # @param payload [Hash] the request body, serialized to JSON
      # @param debug [Boolean] whether to include debug information in the request
      # @return [Request]
      def build_request(action, payload, debug)
        url = base_url + RESOURCES[action]
        FriendlyShipping::Request.new(
          url: url,
          http_method: "POST",
          body: payload.to_json,
          headers: {
            Content_Type: 'application/json',
            Accept: 'application/json',
            Username: login,
            Password: password,
            AccessLicenseNumber: key
          },
          debug: debug
        )
      end

      # @return [String] the test or live base URL, depending on `test`
      def base_url
        test ? TEST_URL : LIVE_URL
      end
    end
  end
end
