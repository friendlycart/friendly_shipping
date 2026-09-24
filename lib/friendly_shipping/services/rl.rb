# frozen_string_literal: true

require "json"

module FriendlyShipping
  module Services
    # API service class for R+L Carriers, a freight/LTL carrier.
    # @see https://www.rlcarriers.com/freight/shipping-software/api R+L API docs
    class RL
      include Dry::Monads::Result::Mixin

      # @return [String] the API key for this carrier
      attr_reader :api_key

      # @return [Boolean] whether to use test API endpoints
      attr_reader :test

      # @return [HttpClient] the HTTP client to use for requests
      attr_reader :client

      # The API base URL for production.
      LIVE_API_BASE = "https://api.rlc.com/"

      # The API base URL for testing.
      TEST_API_BASE = "https://apisandbox.rlc.com/"

      # This carrier's API paths. Used when constructing endpoint URLs.
      API_PATHS = {
        bill_of_lading: "BillOfLading",
        documents: "DocumentRetrieval",
        print_bol: "BillOfLading/PrintBOL",
        pickup_request: "PickupRequest",
        print_shipping_labels: "BillOfLading/PrintShippingLabels",
        rate_quote: "RateQuote",
        transit_times: "TransitTimes"
      }.freeze

      # The maximum length the API allows for a pickup cancellation reason.
      MAX_CANCEL_REASON_LENGTH = 100

      # The R+L Carriers carrier. This is the canonical definition referenced by
      # {FriendlyShipping::LTLCarriers}.
      CARRIER = FriendlyShipping::Carrier.new(
        id: 'rl',
        name: 'R+L Carriers',
        code: 'rl',
        scac: 'RLCA',
        shipping_methods: SHIPPING_METHODS,
        data: {
          scacs: ['RLCA'],
          tracking_url_template: 'https://www.rlcarriers.com/freight/shipping/shipment-tracing?pro=:tracking&docType=PRO'
        }
      )

      # @param [String] api_key the API key for this carrier
      # @param [Boolean] test whether to use test API endpoints
      # @param [HttpClient] client the HTTP client to use for requests
      def initialize(api_key:, test: true, client: nil)
        @api_key = api_key
        @test = test

        error_handler = ApiErrorHandler.new(api_error_class: RL::ApiError)
        @client = client || HttpClient.new(error_handler: error_handler)
      end

      # @return [Success<Array<Carrier>>] the carriers for this service
      def carriers
        Success([CARRIER])
      end

      # Create an LTL Bill of Lading (BOL) and schedule a pickup with R+L Carriers.
      #
      # @param shipment [Physical::Shipment] the shipment for the BOL
      # @param options [BOLOptions] the options for the BOL
      # @return [Success<ApiResult<ShipmentInformation>>, Failure<ApiResult>] the BOL from R+L Carriers
      def create_bill_of_lading(shipment, options:, debug: false)
        request = FriendlyShipping::Request.new(
          url: api_base + API_PATHS[:bill_of_lading],
          http_method: "POST",
          body: SerializeCreateBOLRequest.call(shipment: shipment, options: options).to_json,
          headers: request_headers,
          debug: debug
        )
        client.post(request).bind do |response|
          ParseCreateBOLResponse.call(request: request, response: response)
        end
      end

      # Retrieve an existing binary LTL Bill of Lading (BOL) document for printing. The BOL is appended
      # to the {ShipmentInformation} object's documents array.
      #
      # @param shipment_info [ShipmentInformation] the shipment for the BOL
      # @return [Success<ApiResult<ShipmentDocument>>, Failure<ApiResult>] the binary BOL document from R+L Carriers
      def print_bill_of_lading(shipment_info, debug: false)
        request = FriendlyShipping::Request.new(
          url: api_base + API_PATHS[:print_bol] + "?ProNumber=#{shipment_info.pro_number}",
          http_method: "GET",
          headers: request_headers,
          debug: debug
        )
        client.get(request).bind do |response|
          ParsePrintBOLResponse.call(request: request, response: response).bind do |api_result|
            shipment_info.documents << api_result.data
            Success(api_result)
          end
        end
      end

      # Retrieve binary LTL shipping label documents for printing. The label documents are appended
      # to the {ShipmentInformation} object's documents array.
      #
      # @param shipment_info [ShipmentInformation] the shipment for the labels
      # @param style [Integer] the R+L Carriers shipping label style (between 1 and 13)
      # @see https://rl-cdn.com/docs/rlc/shipping-forms/shipping-label-select.pdf Shipping label styles
      # @param start_position [Integer] the R+L Carriers start position for the first label (between 1 and 10)
      # @param num_labels [Integer] number of labels to print (between 1 and 100)
      # @return [Success<ApiResult<ShipmentDocument>>, Failure<ApiResult>] the binary shipping labels from R+L Carriers
      def print_shipping_labels(shipment_info, style: 1, start_position: 1, num_labels: 4, debug: false)
        request = FriendlyShipping::Request.new(
          url: api_base + API_PATHS[:print_shipping_labels] +
            "?ProNumber=#{shipment_info.pro_number}&" \
            "Style=#{style}&" \
            "StartPosition=#{start_position}&" \
            "NumberOfLabels=#{num_labels}",
          http_method: "GET",
          headers: request_headers,
          debug: debug
        )
        client.get(request).bind do |response|
          ParsePrintShippingLabelsResponse.call(request: request, response: response).bind do |api_result|
            shipment_info.documents << api_result.data
            Success(api_result)
          end
        end
      end

      # Request an LTL shipping rate quote from R+L Carriers.
      #
      # @param shipment [Physical::Shipment] the shipment to quote
      # @param options [RateQuoteOptions] the options for the quote
      #
      # @return [Result<ApiResult<Array<Rate>>>] the rate quote from R+L Carriers
      def rate_quote(shipment, options:, debug: false)
        request = FriendlyShipping::Request.new(
          url: LIVE_API_BASE + API_PATHS[:rate_quote],
          http_method: "POST",
          body: SerializeRateQuoteRequest.call(shipment: shipment, options: options).to_json,
          headers: request_headers,
          debug: debug
        )
        client.post(request).bind do |response|
          ParseRateQuoteResponse.call(request: request, response: response)
        end
      end

      # Request an LTL shipment transit timing from R+L Carriers.
      #
      # @param shipment [Physical::Shipment] the shipment we're timing
      # @param options [RateQuoteOptions] the options for the timing
      #
      # @return [Result<ApiResult<Array<Timing>>>] the transit timing from R+L Carriers
      def transit_times(shipment, options:, debug: false)
        request = FriendlyShipping::Request.new(
          url: LIVE_API_BASE + API_PATHS[:transit_times],
          http_method: "POST",
          body: SerializeTransitTimesRequest.call(shipment: shipment, options: options).to_json,
          headers: request_headers,
          debug: debug
        )
        client.post(request).bind do |response|
          ParseTransitTimesResponse.call(request: request, response: response)
        end
      end

      # Cancel a previously scheduled pickup request.
      #
      # R+L returns an empty message list for a successful cancellation, and returns that
      # same empty success for a pickup request number that doesn't exist. A `Success` here
      # therefore means R+L accepted the request, not that a pickup was cancelled.
      #
      # Cancelling a pickup that is not in a cancellable status *is* reported as an error:
      # only pickups that are Unassigned, Assigned or Dispatched can be cancelled, so
      # cancelling the same pickup twice fails.
      #
      # @see https://technology.rlcarriers.com/api-documentation/pickup-request/ R+L pickup request API docs
      #
      # @param pickup_request_number [String, Integer] the pickup request number to cancel, e.g.
      #   {ShipmentInformation#pickup_request_number} from a create BOL response
      # @param reason [String] why the pickup is being cancelled (maximum {MAX_CANCEL_REASON_LENGTH} characters)
      # @param debug [Boolean] whether to include debugging information in the result
      # @raise [ArgumentError] if the reason exceeds {MAX_CANCEL_REASON_LENGTH} characters
      # @return [Success<ApiResult<Array<String>>>, Failure<ApiResult>] the messages returned from R+L Carriers
      def cancel_pickup(pickup_request_number, reason:, debug: false)
        validate_cancel_reason!(reason)

        request = FriendlyShipping::Request.new(
          url: api_base + API_PATHS[:pickup_request],
          http_method: "DELETE",
          body: {
            PickupRequestId: pickup_request_number.to_i,
            Reason: reason
          }.to_json,
          headers: request_headers,
          debug: debug
        )
        client.delete(request).bind do |response|
          ParseCancelPickupResponse.call(request: request, response: response)
        end
      end

      # Retrieve an existing binary Invoice
      #
      # @param [String] pro_number The PRO number for the Invoice
      #
      # @return [Result<ApiResult<ShipmentDocument>>] The binary Invoice document from R&L
      def get_invoice(pro_number, debug: false)
        request = FriendlyShipping::Request.new(
          url: api_base + API_PATHS[:documents] + "?ProNumber=#{pro_number}&DocumentTypes=Invoice&MediaType=PDF",
          http_method: "GET",
          headers: request_headers,
          debug: debug
        )
        client.get(request).bind do |response|
          ParseInvoiceResponse.call(request: request, response: response)
        end
      end

      private

      # Raises if the given pickup cancellation reason is too long for the API.
      #
      # @param reason [String] the reason to validate
      # @raise [ArgumentError] if the reason exceeds {MAX_CANCEL_REASON_LENGTH} characters
      # @return [void]
      def validate_cancel_reason!(reason)
        return if reason.to_s.length <= MAX_CANCEL_REASON_LENGTH

        raise ArgumentError, "Reason must be #{MAX_CANCEL_REASON_LENGTH} characters or fewer"
      end

      # Returns the content type and API key as a headers hash.
      # @return [Hash]
      def request_headers
        {
          content_type: :json,
          apiKey: api_key
        }
      end

      # Returns the API base URL based on the {test} attribute's value.
      # @return [String]
      def api_base
        test ? TEST_API_BASE : LIVE_API_BASE
      end
    end
  end
end
