# frozen_string_literal: true

require 'nokogiri'

module FriendlyShipping
  module Services
    # Service class for the legacy USPS international rating API (IntlRateV2, XML based).
    #
    # @see https://www.usps.com/business/web-tools-apis/
    class UspsInternational
      include Dry::Monads::Result::Mixin

      # @return [Boolean] whether to use the test (staging) API
      attr_reader :test

      # @return [String] the USPS login (USERID) used to authenticate requests
      attr_reader :login

      # @return [HttpClient] the HTTP client used for requests
      attr_reader :client

      # Maps container names to the codes USPS expects
      CONTAINERS = {
        rectanglular: 'RECTANGULAR',
        roll: 'ROLL',
        variable: 'VARIABLE'
      }.freeze

      # Maps mail type names to the codes USPS expects
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

      # The URL of the USPS staging API
      TEST_URL = 'https://stg-secure.shippingapis.com/ShippingAPI.dll'
      # The URL of the USPS production API
      LIVE_URL = 'https://secure.shippingapis.com/ShippingAPI.dll'

      # The USPS API names for each supported resource
      RESOURCES = {
        rates: 'IntlRateV2',
      }.freeze

      # @param login [String] the USPS login (USERID)
      # @param test [Boolean] whether to use the test (staging) API
      # @param client [HttpClient] the HTTP client to use for requests
      def initialize(login:, test: true, client: HttpClient.new)
        @login = login
        @test = test
        @client = client
      end

      # Get rate estimates from USPS International
      #
      # @param [Physical::Shipment] shipment
      # @param [RateEstimateOptions] options What options
      #    to use for this rate estimate call
      # @param [Boolean] debug Whether to keep debug information on the request
      #
      # @return [Result<ApiResult<Array<Rate>>>] When successfully parsing, an array of rates in a Success Monad.
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

      # @param api [Symbol] a key of {RESOURCES}
      # @param xml [String] the XML request body
      # @param debug [Boolean] whether to keep debug information on the request
      # @return [Request]
      def build_request(api:, xml:, debug:)
        FriendlyShipping::Request.new(
          url: base_url,
          http_method: "POST",
          body: "API=#{RESOURCES[api]}&XML=#{CGI.escape xml}",
          readable_body: xml,
          debug: debug
        )
      end

      # @return [String]
      def base_url
        test ? TEST_URL : LIVE_URL
      end
    end
  end
end
