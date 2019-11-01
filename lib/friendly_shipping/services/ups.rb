# frozen_string_literal: true

require 'dry/monads/result'
require 'friendly_shipping/http_client'
require 'friendly_shipping/services/ups/serialize_access_request'
require 'friendly_shipping/services/ups/serialize_city_state_lookup_request'
require 'friendly_shipping/services/ups/serialize_address_validation_request'
require 'friendly_shipping/services/ups/serialize_rating_service_selection_request'
require 'friendly_shipping/services/ups/serialize_shipment_accept_request'
require 'friendly_shipping/services/ups/serialize_shipment_confirm_request'
require 'friendly_shipping/services/ups/parse_address_validation_response'
require 'friendly_shipping/services/ups/parse_address_classification_response'
require 'friendly_shipping/services/ups/parse_city_state_lookup_response'
require 'friendly_shipping/services/ups/parse_rate_response'
require 'friendly_shipping/services/ups/parse_shipment_confirm_response'
require 'friendly_shipping/services/ups/parse_shipment_accept_response'
require 'friendly_shipping/services/ups/shipping_methods'
require 'friendly_shipping/services/ups/label_options'

module FriendlyShipping
  module Services
    class Ups
      include Dry::Monads::Result::Mixin

      attr_reader :test, :key, :login, :password, :client

      CARRIER = FriendlyShipping::Carrier.new(
        id: 'ups',
        name: 'United Parcel Service',
        code: 'ups',
        shipping_methods: SHIPPING_METHODS
      )

      TEST_URL = 'https://wwwcie.ups.com'
      LIVE_URL = 'https://onlinetools.ups.com'

      RESOURCES = {
        address_validation: '/ups.app/xml/XAV',
        city_state_lookup: '/ups.app/xml/AV',
        rates: '/ups.app/xml/Rate',
        ship_confirm: '/ups.app/xml/ShipConfirm',
        ship_accept: '/ups.app/xml/ShipAccept',
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
      def rate_estimates(shipment, debug: false)
        rate_request_xml = SerializeRatingServiceSelectionRequest.call(shipment: shipment)
        url = base_url + RESOURCES[:rates]
        request = FriendlyShipping::Request.new(
          url: url,
          body: access_request_xml + rate_request_xml,
          debug: debug
        )

        client.post(request).bind do |response|
          ParseRateResponse.call(response: response, request: request, shipment: shipment)
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
          body: access_request_xml + ship_confirm_request_xml,
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
            body: access_request_xml + ship_accept_request_xml,
            debug: debug
          )

          client.post(ship_accept_request).bind do |ship_accept_response|
            ParseShipmentAcceptResponse.call(request: ship_accept_request, response: ship_accept_response)
          end
        end
      end

      # Validate an address.
      # @param [Physical::Location] location The address we want to verify
      # @return [Result<ApiResult<Array<Physical::Location>>>] The response data from UPS encoded in a
      #   `Physical::Location` object. Name and Company name are always nil, the
      #   address lines will be made conformant to what UPS considers right. The returned location will
      #   have the address_type set if possible.
      def address_validation(location, debug: false)
        address_validation_request_xml = SerializeAddressValidationRequest.call(location: location)
        url = base_url + RESOURCES[:address_validation]
        request = FriendlyShipping::Request.new(
          url: url,
          body: access_request_xml + address_validation_request_xml,
          debug: debug
        )

        client.post(request).bind do |response|
          ParseAddressValidationResponse.call(response: response, request: request)
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
          body: access_request_xml + address_validation_request_xml,
          debug: debug
        )

        client.post(request).bind do |response|
          ParseAddressClassificationResponse.call(response: response, request: request)
        end
      end

      # Find city and state for a given ZIP code
      # @param [Physical::Location] location A location object with country and ZIP code set
      # @return [Result<ApiResult<Array<Physical::Location>>>] The response data from UPS encoded in a
      #   `Physical::Location` object. Country, City and ZIP code will be set, everything else nil.
      def city_state_lookup(location, debug: false)
        city_state_lookup_request_xml = SerializeCityStateLookupRequest.call(location: location)
        url = base_url + RESOURCES[:city_state_lookup]
        request = FriendlyShipping::Request.new(
          url: url,
          body: access_request_xml + city_state_lookup_request_xml,
          debug: debug
        )

        client.post(request).bind do |response|
          ParseCityStateLookupResponse.call(response: response, request: request, location: location)
        end
      end

      private

      def access_request_xml
        SerializeAccessRequest.call(key: key, login: login, password: password)
      end

      def base_url
        test ? TEST_URL : LIVE_URL
      end
    end
  end
end
