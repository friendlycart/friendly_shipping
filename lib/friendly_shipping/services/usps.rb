# frozen_string_literal: true

require 'friendly_shipping/http_client'
require 'friendly_shipping/services/usps/shipping_methods'
require 'friendly_shipping/services/usps/serialize_address_validation_request'
require 'friendly_shipping/services/usps/serialize_city_state_lookup_request'
require 'friendly_shipping/services/usps/serialize_rate_request'
require 'friendly_shipping/services/usps/serialize_time_in_transit_request'
require 'friendly_shipping/services/usps/parse_address_validation_response'
require 'friendly_shipping/services/usps/parse_city_state_lookup_response'
require 'friendly_shipping/services/usps/parse_rate_response'
require 'friendly_shipping/services/usps/parse_time_in_transit_response'
require 'friendly_shipping/services/usps/timing_options'
require 'friendly_shipping/services/usps/rate_estimate_options'

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
        address_validation: 'Verify',
        city_state_lookup: 'CityStateLookup',
        rates: 'RateV4',
        timings: 'SDCGetLocations'
      }.freeze

      def initialize(login:, test: true, client: HttpClient.new)
        @login = login
        @test = test
        @client = client
      end

      def carriers
        Success([CARRIER])
      end

      # Get rate estimates from USPS
      #
      # @param [Physical::Shipment] shipment
      # @param [FriendlyShipping::Services::Usps::RateEstimateOptions] options What options
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

      # Get timing estimates from USPS
      #
      # @param [Physical::Shipment] shipment The shipment we want to estimate. Only destination zip and origin zip are used.
      # @param [FriendlyShipping::Services::Usps::TimingOptions] options Options for the timing estimate call
      def timings(shipment, options:, debug: false)
        timings_request_xml = SerializeTimeInTransitRequest.call(shipment: shipment, options: options, login: login)
        request = build_request(api: :timings, xml: timings_request_xml, debug: debug)

        client.post(request).bind do |response|
          ParseTimeInTransitResponse.call(response: response, request: request)
        end
      end

      # Validate an address.
      # @param [Physical::Location] location The address we want to verify
      # @return [Result<ApiResult<Array<Physical::Location>>>] The response data from UPS encoded in a
      #   `Physical::Location` object. Name and Company name are always nil, the
      #   address lines will be made conformant to what USPS considers right. The returned location will
      #   have the address_type set if possible.
      def address_validation(location, debug: false)
        address_validation_request_xml = SerializeAddressValidationRequest.call(location: location, login: login)
        request = build_request(api: :address_validation, xml: address_validation_request_xml, debug: debug)

        client.post(request).bind do |response|
          ParseAddressValidationResponse.call(response: response, request: request)
        end
      end

      # Find city and state for a given ZIP code
      # @param [Physical::Location] location A location object with country and ZIP code set
      # @return [Result<ApiResult<Array<Physical::Location>>>] The response data from USPS encoded in a
      #   `Physical::Location` object. Country, City and ZIP code will be set, everything else nil.
      def city_state_lookup(location, debug: false)
        city_state_lookup_request_xml = SerializeCityStateLookupRequest.call(location: location, login: login)
        request = build_request(api: :city_state_lookup, xml: city_state_lookup_request_xml, debug: debug)

        client.post(request).bind do |response|
          ParseCityStateLookupResponse.call(response: response, request: request)
        end
      end

      private

      def build_request(api:, xml:, debug:)
        FriendlyShipping::Request.new(
          url: base_url,
          body: "API=#{RESOURCES[api]}&XML=#{CGI.escape xml}",
          debug: debug
        )
      end

      def base_url
        test ? TEST_URL : LIVE_URL
      end
    end
  end
end
