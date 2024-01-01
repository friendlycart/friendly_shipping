# frozen_string_literal: true

require 'dry/monads'
require 'friendly_shipping/http_client'
require 'friendly_shipping/services/ship_engine/api_error'
require 'friendly_shipping/services/ship_engine/parse_carrier_response'
require 'friendly_shipping/services/ship_engine/serialize_address_validation_request'
require 'friendly_shipping/services/ship_engine/serialize_label_shipment'
require 'friendly_shipping/services/ship_engine/serialize_rate_estimate_request'
require 'friendly_shipping/services/ship_engine/serialize_rates_request'
require 'friendly_shipping/services/ship_engine/serialize_address_residential_indicator'
require 'friendly_shipping/services/ship_engine/parse_address_validation_response'
require 'friendly_shipping/services/ship_engine/parse_label_response'
require 'friendly_shipping/services/ship_engine/parse_void_response'
require 'friendly_shipping/services/ship_engine/parse_rate_estimates_response'
require 'friendly_shipping/services/ship_engine/parse_rates_response'
require 'friendly_shipping/services/ship_engine/rate_estimates_options'
require 'friendly_shipping/services/ship_engine/rates_item_options'
require 'friendly_shipping/services/ship_engine/rates_package_options'
require 'friendly_shipping/services/ship_engine/rates_options'
require 'friendly_shipping/services/ship_engine/label_options'
require 'friendly_shipping/services/ship_engine/label_package_options'

module FriendlyShipping
  module Services
    # API service class for ShipEngine, a shipping API supporting UPS, USPS, etc.
    # @see https://www.shipengine.com/docs/ ShipEngine API docs
    class ShipEngine
      # The API base URL.
      API_BASE = "https://api.shipengine.com/v1/"

      # The API paths. Used when constructing endpoint URLs.
      API_PATHS = {
        carriers: "carriers",
        labels: "labels"
      }.freeze

      # @param token [String] the API token
      # @param test [Boolean] whether to use test API endpoints
      # @param client [HttpClient] optional custom HTTP client to use for requests
      def initialize(token:, test: true, client: nil)
        @token = token
        @test = test

        error_handler = ApiErrorHandler.new(api_error_class: ShipEngine::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
      end

      # Get configured carriers.
      #
      # @param debug [Boolean] whether to attach debugging information to the response
      # @return [ApiResult<Array<Carrier>>, Failure<ApiFailure>] carriers configured in your account
      def carriers(debug: false)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:carriers],
          http_method: "GET",
          headers: request_headers,
          debug: debug
        )
        client.get(request).fmap do |response|
          ParseCarrierResponse.call(request: request, response: response)
        end
      end

      # Get rates.
      #
      # @param shipment [Physical::Shipment] the shipment for which we're getting rates
      # @param options [RatesOptions] the options for getting rates (see object description)
      #
      # @return [Success<ApiResult<Array<Rate>>>, Failure<ApiFailure<Array<String>>] When successfully parsing, an
      #   array of rates in a Success Monad. When the parsing is not successful or ShipEngine can't give us rates,
      #   a Failure monad containing something that can be serialized into an error message using `to_s`.
      def rates(shipment, options:, debug: false)
        request = FriendlyShipping::Request.new(
          url: "#{FriendlyShipping::Services::ShipEngine::API_BASE}rates",
          http_method: "POST",
          body: SerializeRatesRequest.call(shipment: shipment, options: options).to_json,
          headers: request_headers,
          debug: debug
        )
        client.post(request).bind do |response|
          ParseRatesResponse.call(response: response, request: request, options: options)
        end
      end

      # Get rate estimates.
      #
      # @param shipment [Physical::Shipment] the shipment for which we're getting rate estimates
      # @param options [RateEstimatesOptions] the options for getting rate estimates (see object description)
      #
      # @return [Success<ApiResult<Array<Rate>>>, Failure<ApiFailure<Array<String>>>] When successfully parsing, an
      #   array of rates in a Success Monad. When the parsing is not successful or ShipEngine can't give us rates,
      #   a Failure monad containing something that can be serialized into an error message using `to_s`.
      def rate_estimates(shipment, options: FriendlyShipping::Services::ShipEngine::RateEstimatesOptions.new, debug: false)
        request = FriendlyShipping::Request.new(
          url: "#{API_BASE}rates/estimate",
          http_method: "POST",
          body: SerializeRateEstimateRequest.call(shipment: shipment, options: options).to_json,
          headers: request_headers,
          debug: debug
        )
        client.post(request).bind do |response|
          ParseRateEstimatesResponse.call(response: response, request: request, options: options)
        end
      end

      # ShipEngine returns timings as part of the rate estimates response
      alias_method :timings, :rate_estimates

      # Get shipping labels.
      #
      # @param shipment [Physical::Shipment] The shipment for which we're getting labels.
      #   Note: Some ShipEngine carriers, notably USPS, only support one package per shipment, and that's
      #   all that the integration supports at this point.
      # @param options [LabelOptions] the options for getting labels (see object description)
      # @return [ApiResult<Array<Label>>, Failure<ApiFailure>] the shipping labels
      def labels(shipment, options:)
        request = FriendlyShipping::Request.new(
          url: API_BASE + API_PATHS[:labels],
          http_method: "POST",
          body: SerializeLabelShipment.call(shipment: shipment, options: options, test: test).to_json,
          headers: request_headers
        )
        client.post(request).fmap do |response|
          ParseLabelResponse.call(request: request, response: response)
        end
      end

      # Void a shipping label.
      #
      # @param label [Label] the label to void
      # @param debug [Boolean] whether to include debugging information in the result
      # @return [Success<ApiResult<String>>, Failure<ApiFailure<String>>] the success or failure message
      def void(label, debug: false)
        request = FriendlyShipping::Request.new(
          url: "#{API_BASE}labels/#{label.id}/void",
          http_method: "PUT",
          body: '',
          headers: request_headers,
          debug: debug
        )
        client.put(request).bind do |response|
          ParseVoidResponse.call(request: request, response: response)
        end
      end

      # Validate an address using ShipEngine
      #
      # @param location [Physical::Location] the address to validate
      # @return [Success<ApiResult<Array<Physical::Location>>>, Failure<ApiFailure>]
      def validate_address(location, debug: false)
        request = FriendlyShipping::Request.new(
          url: "#{API_BASE}addresses/validate",
          http_method: "POST",
          body: SerializeAddressValidationRequest.call(location: location).to_json,
          headers: request_headers,
          debug: debug
        )
        client.post(request).bind do |response|
          ParseAddressValidationResponse.call(response: response, request: request)
        end
      end

      alias_method :city_state_lookup, :validate_address

      private

      # @return [String] the API token
      attr_reader :token

      # @return [Boolean] whether to use test API endpoints
      attr_reader :test

      # @return [HttpClient] the HTTP client to use for requests
      attr_reader :client

      # Returns the content type and API key as a headers hash.
      # @return [Hash]
      def request_headers
        {
          content_type: :json,
          'api-key': token
        }
      end
    end
  end
end
