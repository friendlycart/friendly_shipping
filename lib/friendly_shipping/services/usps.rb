# frozen_string_literal: true

require 'friendly_shipping/services/usps/client'
require 'friendly_shipping/services/usps/shipping_methods'
require 'friendly_shipping/services/usps/serialize_address_validation_request'
require 'friendly_shipping/services/usps/serialize_rate_request'
require 'friendly_shipping/services/usps/parse_address_validation_response'
require 'friendly_shipping/services/usps/parse_rate_response'

module FriendlyShipping
  module Services
    class Usps
      include Dry::Monads::Result::Mixin

      attr_reader :test, :login, :client

      CARRIER = FriendlyShipping::Carrier.new(
        id: 'usps',
        name: 'United States Postal Service',
        code: 'usps',
        shipping_methods: SHIPPING_METHODS
      )

      TEST_URL = 'https://stg-secure.shippingapis.com/ShippingAPI.dll'
      LIVE_URL = 'https://secure.shippingapis.com/ShippingAPI.dll'

      RESOURCES = {
        rates: 'RateV4',
      }.freeze

      def initialize(login:, test: true, client: Client)
        @login = login
        @test = test
        @client = client
      end

      def carriers
        Success([CARRIER])
      end

      # Get rate estimates from USPS
      #
      # @param [Physical::Shipment] shipment The shipment object we're trying to get results for
      #   USPS returns rates on a package-by-package basis, so the options for obtaining rates are
      #   set on the [Physical::Package.container.properties] hash. The possible options are:
      #   @property [Symbol] box_name The type of box we want to get rates for. Has to be one of the keys
      #      of FriendlyShipping::Services::Usps::CONTAINERS.
      #   @property [Boolean] commercial_pricing Whether we prefer commercial pricing results or retail results
      #   @property [Boolean] hold_for_pickup Whether we want a rate with Hold For Pickup Service
      # @param [Physical::ShippingMethod] shipping_method The shipping method ("service" in USPS parlance) we want
      #   to get rates for.
      #
      # @return [Result<Array<FriendlyShipping::Rate>>] When successfully parsing, an array of rates in a Success Monad.
      #   When the parsing is not successful or USPS can't give us rates, a Failure monad containing something that
      #   can be serialized into an error message using `to_s`.
      def rate_estimates(shipment, options = {})
        rate_request_xml = SerializeRateRequest.call(shipment: shipment, login: login, shipping_method: options[:shipping_method])
        request = FriendlyShipping::Request.new(url: base_url, body: "API=#{RESOURCES[:rates]}&XML=#{CGI.escape rate_request_xml}")

        client.post(request).bind do |response|
          ParseRateResponse.call(response: response, request: request, shipment: shipment)
        end
      end

      private

      def base_url
        test ? TEST_URL : LIVE_URL
      end
    end
  end
end
