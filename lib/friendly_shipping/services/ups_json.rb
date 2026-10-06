# frozen_string_literal: true

require "json"

module FriendlyShipping
  module Services
    # Service class for interacting with the UPS JSON (OAuth) API: rates, transit timings, labels,
    # address classification, city/state lookup and voiding labels.
    class UpsJson
      include Dry::Monads::Result::Mixin

      attr_reader :access_token, :test, :client

      # The carrier object for UPS, including all known shipping methods.
      CARRIER = FriendlyShipping::Carrier.new(
        id: 'ups',
        name: 'United Parcel Service',
        code: 'ups',
        shipping_methods: SHIPPING_METHODS
      )

      # Base URL of the UPS test (customer integration) environment.
      TEST_URL = 'https://wwwcie.ups.com'
      # Base URL of the UPS production environment.
      LIVE_URL = 'https://onlinetools.ups.com'

      # @param access_token [String] the OAuth access token used to authorize API requests
      # @param test [Boolean] whether to use the UPS test environment (default) instead of production
      # @param client [#post, #delete, nil] the HTTP client to use. Defaults to an `HttpClient` that raises
      #   `UpsJson::ApiError` on failed requests.
      def initialize(access_token:, test: true, client: nil)
        @access_token = access_token
        @test = test
        error_handler = ApiErrorHandler.new(api_error_class: UpsJson::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
      end

      # Returns the carriers supported by this service.
      # @return [Result<Array<Carrier>>] a result wrapping an array containing only the UPS carrier
      def carriers
        Success([CARRIER])
      end

      # Creates an access token to be used for future API requests.
      #
      # @param client_id [String] the Client ID of your UPS application
      # @param client_secret [String] the Client Secret of your UPS application
      # @param merchant_id [String] the shipper number associated with your UPS application
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [ApiResult<AccessToken>] the access token
      def create_access_token(
        client_id:,
        client_secret:,
        merchant_id:,
        debug: false
      )
        request = FriendlyShipping::Request.new(
          url: "#{base_url}/security/v1/oauth/token",
          http_method: "POST",
          body: "grant_type=client_credentials",
          headers: {
            Authorization: "Basic #{Base64.urlsafe_encode64("#{client_id}:#{client_secret}")}",
            Content_Type: "application/x-www-form-urlencoded",
            'X-Merchant-Id': merchant_id,
            Accept: "application/json"
          },
          debug: debug
        )
        client.post(request).fmap do |response|
          hash = JSON.parse(response.body)
          FriendlyShipping::ApiResult.new(
            AccessToken.new(
              expires_in: hash['expires_in'],
              issued_at: hash['issued_at'],
              raw_token: hash['access_token']
            ),
            original_request: request,
            original_response: response
          )
        end
      end

      # Get rates for a shipment
      # @param shipment [Physical::Shipment] The shipment we want to get rates for
      # @param options [RatesOptions] What options to use for this rates request
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Result<ApiResult<Array<Rate>>>] The rates returned from UPS encoded in a
      #   `FriendlyShipping::ApiResult` object.
      def rates(shipment, options:, debug: false)
        rate_or_shop = options.shipping_method ? "Rate" : "Shop"
        url = "#{base_url}/api/rating/v#{options.sub_version || '1'}/#{rate_or_shop}"
        headers = required_headers(access_token)
        rates_request_body = GenerateRatesPayload.call(shipment: shipment, options: options).to_json

        request = FriendlyShipping::Request.new(
          url: url,
          http_method: "POST",
          headers: headers,
          body: rates_request_body,
          debug: debug
        )

        client.post(request).bind do |response|
          ParseRatesResponse.call(response: response, request: request, shipment: shipment)
        end
      end

      alias_method :rate_estimates, :rates

      # Get timing information for a shipment
      # @param shipment [Physical::Shipment] The shipment we want to estimate timings for
      # @param options [TimingsOptions] Options for this call
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Result<ApiResult<Array<Timing>>>] The timings returned from UPS encoded in a
      #   `FriendlyShipping::ApiResult` object.
      def timings(shipment, options:, debug: false)
        url = "#{base_url}/api/shipments/v1/transittimes"
        headers = required_headers(access_token).merge(
          "transId" => SecureRandom.uuid,
          "transactionSrc" => "testing" # this is a required field according to https://developer.ups.com/api/reference?loc=en_US#operation/TimeInTransit
        )
        timings_request_body = GenerateTimingsPayload.call(shipment: shipment, options: options).to_json

        request = FriendlyShipping::Request.new(
          url: url,
          http_method: "POST",
          headers: headers,
          body: timings_request_body,
          debug: debug
        )

        client.post(request).bind do |response|
          ParseTimingsResponse.call(response: response, request: request, shipment: shipment)
        end
      end

      # Generate labels for a shipment, aka by UPS as the Shipping Shipment api:
      #   https://developer.ups.com/api/reference?loc=en_US#tag/Shipping_other
      # @param shipment [Physical::Shipment] The shipment we want to create labels for
      # @param options [LabelOptions] Options for this call
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Result<ApiResult<Array<Label>>>] The labels returned from UPS encoded in a
      #   `FriendlyShipping::ApiResult` object.
      def labels(shipment, options:, debug: false)
        url = "#{base_url}/api/shipments/v#{options.sub_version || '2205'}/ship"
        # the RequestOption field in the payload is documented as doing city validation but it does not
        url += "?additionaladdressvalidation=city" if options.validate_address
        headers = required_headers(access_token)
        body = GenerateLabelsPayload.call(shipment: shipment, options: options).to_json
        request = FriendlyShipping::Request.new(url: url, http_method: "POST", headers: headers, body: body, debug: debug)

        client.post(request).bind do |response|
          ParseLabelsResponse.call(response: response, request: request)
        end
      end

      # Classify an address.
      # @param location [Physical::Location] The address we want to classify
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Result<ApiResult<String>>] Either `"commercial"`, `"residential"`, or `"unknown"`
      def address_classification(location, debug: false)
        url = "#{base_url}/api/addressvalidation/v1/2"
        headers = required_headers(access_token)
        body = GenerateAddressClassificationPayload.call(location: location).to_json

        request = FriendlyShipping::Request.new(
          url: url,
          http_method: "POST",
          headers: headers,
          body: body,
          debug: debug
        )

        client.post(request).bind do |response|
          ParseAddressClassificationResponse.call(response: response, request: request)
        end
      end

      # Find city and state for a given ZIP code
      # @param location [Physical::Location] A location object with country and ZIP code set
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Result<ApiResult<Array<Physical::Location>>>] The response data from UPS encoded in a
      #   `Physical::Location` object. Country, City and ZIP code will be set, everything else nil.
      def city_state_lookup(location, debug: false)
        url = "#{base_url}/api/addressvalidation/v2/1"
        headers = required_headers(access_token)
        body = GenerateCityStateLookupPayload.call(location: location).to_json

        request = FriendlyShipping::Request.new(
          url: url,
          http_method: "POST",
          headers: headers,
          body: body,
          debug: debug
        )

        client.post(request).bind do |response|
          ParseCityStateLookupResponse.call(response: response, request: request)
        end
      end

      # Void a label, aka by UPS as the Shipping Void Shipment api:
      #   https://developer.ups.com/api/reference?loc=en_US#tag/Shipping_other
      # @param label [Label] The label to be voided
      # @param debug [Boolean] whether to append debug information to the API result
      # @return [Result<ApiResult>] The VoidShipmentResponse body from UPS.
      def void(label, debug: false)
        # The docs say to use both the shipment_id and tracking number, but the tracking number seems to work alone.
        # url = "#{base_url}/api/shipments/v1/void/cancel/#{label.shipment_id}?trackingNumber=#{label.tracking_number}"
        url = "#{base_url}/api/shipments/v1/void/cancel/#{label.tracking_number}"
        headers = required_headers(access_token)
        request = FriendlyShipping::Request.new(url: url, http_method: "DELETE", headers: headers, debug: debug)

        client.delete(request).bind do |response|
          ParseVoidResponse.call(response: response, request: request)
        end
      end

      private

      # @param access_token [String] the OAuth access token
      # @return [Hash{String => String}] the headers required for UPS JSON API requests
      def required_headers(access_token)
        {
          "Authorization" => "Bearer #{access_token}",
          "Content-Type" => "application/json",
          "Accept" => "application/json"
        }
      end

      # @return [String] the test or live base URL, depending on the `test` setting
      def base_url
        test ? TEST_URL : LIVE_URL
      end
    end
  end
end
