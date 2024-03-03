# frozen_string_literal: true

require 'dry/monads'
require 'friendly_shipping/http_client'
require 'friendly_shipping/services/ship_engine/api_error'
require 'friendly_shipping/services/ship_engine/parse_carrier_response'
require 'friendly_shipping/services/ship_engine/serialize_address_validation_request'
require 'friendly_shipping/services/ship_engine/serialize_label_shipment'
require 'friendly_shipping/services/ship_engine/serialize_rate_estimate_request'
require 'friendly_shipping/services/ship_engine/serialize_rates_request'
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
    class ShipEngine
      API_BASE = "https://api.shipengine.com/v1/"
      API_PATHS = {
        carriers: "carriers",
        labels: "labels"
      }.freeze

      def initialize(token:, test: true, client: nil)
        @token = token
        @test = test

        error_handler = ApiErrorHandler.new(api_error_class: ShipEngine::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
      end

      # Get configured carriers from ShipEngine
      #
      # @return [Result<ApiResult<Array<Carrier>>>] Carriers configured in your account
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

      # Get rates from ShipEngine
      #
      # @param [Physical::Shipment] shipment The shipment object we're trying to get results for
      # @options [FriendlyShipping::Services::ShipEngine::RatesOptions] The options relevant to rates. See object description.
      #
      # @return [Result<ApiResult<Array<FriendlyShipping::Rate>>>] When successfully parsing, an array of rates in a Success Monad.
      #   When the parsing is not successful or ShipEngine can't give us rates, a Failure monad containing something that
      #   can be serialized into an error message using `to_s`.
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

      # Get rate estimates from ShipEngine
      #
      # @param [Physical::Shipment] shipment The shipment object we're trying to get results for
      #
      # @options [FriendlyShipping::Services::ShipEngine::RateEstimatesOptions] The options relevant to estimating rates. See object description.
      #
      # @return [Result<ApiResult<Array<FriendlyShipping::Rate>>>] When successfully parsing, an array of rates in a Success Monad.
      #   When the parsing is not successful or ShipEngine can't give us rates, a Failure monad containing something that
      #   can be serialized into an error message using `to_s`.
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

      # Get label(s) from ShipEngine
      #
      # @param [Physical::Shipment] shipment The shipment object we're trying to get labels for
      #   Note: Some ShipEngine carriers, notably USPS, only support one package per shipment, and that's
      #   all that the integration supports at this point.
      # @param [FriendlyShipping::Services::ShipEngine::LabelOptions] options The options relevant to estimating rates. See object description.
      #
      # @return [Result<ApiResult<Array<FriendlyShipping::Label>>>] The label returned.
      #
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

      # Void a ShipEngine label
      #
      # @param label [FriendlyShipping::Label]
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Result<ApiResult<String>>] the result message
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

      # @param locations [Array<Physical::Location>]
      # @return [Success<ApiResult>, Failure<ApiFailure>]
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

      attr_reader :token, :test, :client

      def request_headers
        {
          content_type: :json,
          'api-key': token
        }
      end
    end
  end
end
