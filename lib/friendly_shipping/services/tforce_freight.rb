# frozen_string_literal: true

require 'dry/monads'
require 'friendly_shipping/http_client'
require 'friendly_shipping/services/tforce_freight/shipping_methods'
require 'friendly_shipping/services/tforce_freight/rates_options'
require 'friendly_shipping/services/tforce_freight/rates_package_options'
require 'friendly_shipping/services/tforce_freight/rates_item_options'
require 'friendly_shipping/services/tforce_freight/parse_rates_response'
require 'friendly_shipping/services/tforce_freight/generate_rates_request_hash'
require 'friendly_shipping/services/tforce_freight/api_error'

module FriendlyShipping
  module Services
    class TForceFreight
      include Dry::Monads[:result]

      attr_reader :access_token, :test, :client

      CARRIER = FriendlyShipping::Carrier.new(
        id: 'tforce_freight',
        name: 'TForce Freight',
        code: 'tforce_freight-freight',
        shipping_methods: SHIPPING_METHODS
      )

      BASE_URL = 'https://api.tforcefreight.com'

      RESOURCES = {
        rates: '/rating/getRate',
      }.freeze

      def initialize(access_token:, test: true, client: nil)
        @access_token = access_token
        @test = test

        error_handler = ApiErrorHandler.new(api_error_class: TForceFreight::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
      end

      def carriers
        Success([CARRIER])
      end

      # Get rates for a shipment
      # @param [Physical::Shipment] shipment The shipment for which we want to get rates
      # @param [FriendlyShipping::Services::TForceFreight::RatesOptions] options Options for obtaining rates for this shipment.
      # @return [Result<ApiResult<Array<Rate>>>] The rates returned from UPS encoded in a
      #   `FriendlyShipping::ApiResult` object.
      def rates(shipment, options:, debug: false)
        freight_rate_request_hash = GenerateRatesRequestHash.call(shipment: shipment, options: options)
        request = build_request(:rates, freight_rate_request_hash, debug)

        client.post(request).fmap do |response|
          ParseRatesResponse.call(response: response, request: request)
        end
      end

      private

      def build_request(action, payload, debug)
        url = BASE_URL + RESOURCES[action] + "?api-version=#{api_version}"
        FriendlyShipping::Request.new(
          url: url,
          http_method: "POST",
          body: payload.to_json,
          headers: {
            Content_Type: "application/json",
            Accept: "application/json",
            Authorization: "Bearer #{access_token}"
          },
          debug: debug
        )
      end

      def api_version
        test ? "cie-v1" : "v1"
      end
    end
  end
end
