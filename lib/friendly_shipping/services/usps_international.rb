# frozen_string_literal: true

require 'friendly_shipping/http_client'
require 'friendly_shipping/services/usps_international/shipping_methods'
require 'friendly_shipping/services/usps_international/serialize_rate_request'
require 'friendly_shipping/services/usps_international/parse_rate_response'
require 'friendly_shipping/services/usps_international/rate_estimate_options'

module FriendlyShipping
  module Services
    class UspsInternational
      include Dry::Monads[:result]

      attr_reader :test, :login, :client

      CONTAINERS = {
        rectanglular: 'RECTANGULAR',
        roll: 'ROLL',
        variable: 'VARIABLE'
      }.freeze

      MAIL_TYPES = {
        all: 'ALL',
        airmail: 'AIRMAIL MBAG',
        envelope: 'ENVELOPE',
        flat_rate: 'FLATRATE',
        letter: 'LETTER',
        large_envelope: 'LARGEENVELOPE',
        package: 'PACKAGE',
        post_cards: 'POSTCARDS'
      }.freeze

      TEST_URL = 'https://stg-secure.shippingapis.com/ShippingAPI.dll'
      LIVE_URL = 'https://secure.shippingapis.com/ShippingAPI.dll'

      RESOURCES = {
        rates: 'IntlRateV2',
      }.freeze

      def initialize(login:, test: true, client: HttpClient.new)
        @login = login
        @test = test
        @client = client
      end

      # Get rate estimates from USPS International
      #
      # @param [Physical::Shipment] shipment
      # @param [FriendlyShipping::Services::UspsInternational::RateEstimateOptions] options What options
      #    to use for this rate estimate call
      #
      # @return [Result<Array<FriendlyShipping::Rate>>] When successfully parsing, an array of rates in a Success Monad.
      #   When the parsing is not successful or USPS can't give us rates, a Failure monad containing something that
      #   can be serialized into an error message using `to_s`.
      def rate_estimates(shipment, options: RateEstimateOptions.new, debug: false)
        rate_request_xml = SerializeRateRequest.call(shipment: shipment, login: login, options: options)
        request = build_request(api: :rates, xml: rate_request_xml, debug: debug)
        client.post(request).bind do |response|
          ParseRateResponse.call(response: response, request: request, shipment: shipment, options: options)
        end
      end

      private

      def build_request(api:, xml:, debug:)
        FriendlyShipping::Request.new(
          url: base_url,
          http_method: "POST",
          body: "API=#{RESOURCES[api]}&XML=#{CGI.escape xml}",
          readable_body: xml,
          debug: debug
        )
      end

      def base_url
        test ? TEST_URL : LIVE_URL
      end
    end
  end
end
