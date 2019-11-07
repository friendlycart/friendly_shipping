# frozen_string_literal: true

require 'dry/monads/result'
require 'friendly_shipping/http_client'
require 'friendly_shipping/services/ups_freight/shipping_methods'
require 'friendly_shipping/services/ups_freight/rates_options'
require 'friendly_shipping/services/ups_freight/rates_package_options'
require 'friendly_shipping/services/ups_freight/rates_item_options'
require 'friendly_shipping/services/ups_freight/parse_freight_rate_response'
require 'friendly_shipping/services/ups_freight/generate_freight_rate_request_hash'
require 'friendly_shipping/services/ups_freight/generate_ups_security_hash'

module FriendlyShipping
  module Services
    class UpsFreight
      include Dry::Monads::Result::Mixin

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
        rates: '/rest/FreightRate'
      }.freeze

      def initialize(key:, login:, password:, test: true, client: HttpClient.new)
        @key = key
        @login = login
        @password = password
        @test = test
        @client = client
      end

      def carriers
        Success([CARRIER])
      end

      # Get rates for a shipment
      # @param [Physical::Shipment] location The shipment we want to get rates for
      # @return [Result<ApiResult<Array<Rate>>>] The rates returned from UPS encoded in a
      #   `FriendlyShipping::ApiResult` object.
      def rate_estimates(shipment, options:, debug: false)
        freight_rate_request_hash = GenerateFreightRateRequestHash.call(shipment: shipment, options: options)
        url = base_url + RESOURCES[:rates]
        request = FriendlyShipping::Request.new(
          url: url,
          body: authentication_hash.merge(freight_rate_request_hash).to_json,
          debug: debug
        )

        client.post(request).bind do |response|
          ParseFreightRateResponse.call(response: response, request: request)
        end
      end

      private

      def authentication_hash
        GenerateUpsSecurityHash.call(key: key, login: login, password: password)
      end

      def base_url
        test ? TEST_URL : LIVE_URL
      end
    end
  end
end
