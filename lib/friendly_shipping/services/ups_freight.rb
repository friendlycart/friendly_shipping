# frozen_string_literal: true

require 'dry/monads'
require 'friendly_shipping/http_client'
require 'friendly_shipping/services/ups_freight/shipping_methods'
require 'friendly_shipping/services/ups_freight/rates_options'
require 'friendly_shipping/services/ups_freight/label_options'
require 'friendly_shipping/services/ups_freight/rates_package_options'
require 'friendly_shipping/services/ups_freight/rates_item_options'
require 'friendly_shipping/services/ups_freight/label_package_options'
require 'friendly_shipping/services/ups_freight/label_item_options'
require 'friendly_shipping/services/ups_freight/label_document_options'
require 'friendly_shipping/services/ups_freight/label_email_options'
require 'friendly_shipping/services/ups_freight/label_pickup_options'
require 'friendly_shipping/services/ups_freight/label_delivery_options'
require 'friendly_shipping/services/ups_freight/pickup_request_options'
require 'friendly_shipping/services/ups_freight/parse_freight_label_response'
require 'friendly_shipping/services/ups_freight/parse_freight_rate_response'
require 'friendly_shipping/services/ups_freight/generate_freight_rate_request_hash'
require 'friendly_shipping/services/ups_freight/generate_freight_ship_request_hash'
require 'friendly_shipping/services/ups_freight/api_error'

module FriendlyShipping
  module Services
    class UpsFreight
      include Dry::Monads[:result]

      attr_reader :test, :key, :login, :password, :client

      CARRIER = FriendlyShipping::Carrier.new(
        id: 'ups_freight',
        name: 'United Parcel Service LTL',
        code: 'ups-freight',
        shipping_methods: SHIPPING_METHODS
      )

      TEST_URL = 'https://wwwcie.ups.com'
      LIVE_URL = 'https://onlinetools.ups.com'

      RESOURCES = {
        rates: '/ship/v1801/freight/rating/ground',
        labels: '/ship/v1607/freight/shipments/Ground'
      }.freeze

      def initialize(key:, login:, password:, test: true, client: nil)
        @key = key
        @login = login
        @password = password
        @test = test

        error_handler = ApiErrorHandler.new(api_error_class: UpsFreight::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
      end

      def carriers
        Success([CARRIER])
      end

      # Get rates for a shipment
      # @param [Physical::Shipment] shipment The shipment we want to get rates for
      # @param [FriendlyShipping::Services::UpsFreight::RatesOptions] options Options for obtaining rates for this shipment.
      # @return [Result<ApiResult<Array<Rate>>>] The rates returned from UPS encoded in a
      #   `FriendlyShipping::ApiResult` object.
      def rate_estimates(shipment, options:, request_generator: GenerateFreightRateRequestHash, debug: false)
        freight_rate_request_hash = request_generator.call(shipment: shipment, options: options)
        request = build_request(:rates, freight_rate_request_hash, debug)

        client.post(request).fmap do |response|
          ParseFreightRateResponse.call(response: response, request: request)
        end
      end

      # Get labels for a shipment
      # @param [Physical::Shipment] shipment The shipment we want to get rates for
      # @param [FriendlyShipping::Services::UpsFreight::LabelOptions] options Options for shipping this shipment.
      # @return [Result<ApiResult<ShipmentInformation>] The information that you need for shipping this shipment.
      def labels(shipment, options:, request_generator: GenerateFreightShipRequestHash, debug: false)
        freight_ship_request_hash = request_generator.call(shipment: shipment, options: options)
        request = build_request(:labels, freight_ship_request_hash, debug)

        client.post(request).fmap do |response|
          ParseFreightLabelResponse.call(response: response, request: request)
        end
      end

      private

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

      def base_url
        test ? TEST_URL : LIVE_URL
      end
    end
  end
end
