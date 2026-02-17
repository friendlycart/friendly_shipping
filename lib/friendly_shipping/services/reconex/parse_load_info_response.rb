# frozen_string_literal: true

require "base64"

module FriendlyShipping
  module Services
    class Reconex
      # Parses a Reconex GetLoadInfo response into an array of LoadInfo objects.
      class ParseLoadInfoResponse
        extend Dry::Monads::Result::Mixin

        # Document keys in the API response mapped to document type symbols.
        DOCUMENT_KEYS = {
          "billOfLadingDocument" => :bol,
          "shippingLabelDocument" => :label,
          "rateConfirmationDocument" => :rate_confirmation,
          "carrieDocsFile" => :carrier_docs
        }.freeze

        class << self
          # @param request [Request] the original request
          # @param response [Response] the response to parse
          # @return [Success<ApiResult<Array<LoadInfo>>>, Failure<ApiResult>]
          def call(request:, response:)
            json = JSON.parse(response.body)

            errors = json.fetch("errors", [])
            if errors.any?
              return Failure(
                ApiResult.new(
                  errors.join(", "),
                  original_request: request,
                  original_response: response
                )
              )
            end

            load_details = json.fetch("loadDetails", []).map do |detail|
              parse_load_detail(detail)
            end

            Success(
              ApiResult.new(
                load_details,
                original_request: request,
                original_response: response
              )
            )
          end

          private

          # @param detail [Hash] a single load detail from the response
          # @return [LoadInfo]
          def parse_load_detail(detail)
            LoadInfo.new(
              load_id: detail["loadID"],
              ship_date: detail["shipDate"],
              carrier_booked: detail["carrierBooked"],
              pro_number: detail["proNumber"],
              confirmation_number: detail["confirmationNumber"],
              tracking_link: detail["trackingLink"],
              load_status_detail: detail["loadStatusDetail"],
              billing_id: detail["billingID"],
              po_number: detail["poNumber"],
              custom_id: detail["customID"],
              customer_billing: detail["customerBilling"],
              origin_info: parse_location(detail["originInfo"]),
              destination_info: parse_location(detail["destinationInfo"]),
              total_weight: detail["totalWeight"],
              total_shipping_qty: detail["totalShippingQty"],
              shipping_unit: detail["shippingUnit"],
              special_instructions: detail["specialInstructions"],
              notes: detail["notes"],
              load_status_id: detail["loadStatusId"],
              delivery_date: detail["deliveryDate"],
              cust_charge: detail["custCharge"],
              freight_charge: detail["freightCharge"],
              access: detail["access"],
              base: detail["base"],
              fsc: detail["fsc"],
              insurance_fee: detail["insuranceFee"],
              mileage: detail["mileage"],
              tracking_status: parse_tracking_status(detail["trackingStatus"]),
              documents: parse_documents(detail)
            )
          end

          # @param detail [Hash] a single load detail from the response
          # @return [Array<Document>]
          def parse_documents(detail)
            DOCUMENT_KEYS.each_with_object([]) do |(key, type), docs|
              doc_data = detail[key]
              next if doc_data.nil?
              next if doc_data["fileContent"].nil? || doc_data["fileContent"].empty?

              docs << Document.new(
                document_type: type,
                filename: doc_data["fileName"],
                format: doc_data["extension"]&.downcase&.to_sym || :pdf,
                binary: Base64.decode64(doc_data["fileContent"])
              )
            end
          end

          # @param location [Hash, nil] location info from the response
          # @return [Hash, nil]
          def parse_location(location)
            return if location.nil?

            {
              name: location["name"],
              street1: location["street1"],
              street2: location["street2"],
              city: location["city"],
              state: location["state"],
              postal_code: location["postalCode"],
              country: location["country"]
            }
          end

          # @param events [Array<Hash>, nil] tracking status events from the response
          # @return [Array<Hash>]
          def parse_tracking_status(events)
            return [] if events.nil?

            events.map do |event|
              {
                time: event["time"],
                status: event["status"],
                message: event["message"],
                carrier_eta: event["carrierETA"],
                updated_on: event["updateOn"]
              }
            end
          end
        end
      end
    end
  end
end
