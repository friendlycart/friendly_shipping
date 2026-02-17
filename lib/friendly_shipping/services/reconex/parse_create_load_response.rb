# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Parses a Reconex CreateLoad response into a ShipmentInformation object.
      class ParseCreateLoadResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the original request
          # @param response [Response] the response to parse
          # @return [Success<ApiResult<ShipmentInformation>>, Failure<ApiResult>]
          def call(request:, response:)
            json = JSON.parse(response.body)

            errors = parse_errors(json)
            if errors.any?
              return Failure(
                ApiResult.new(
                  errors.join(", "),
                  original_request: request,
                  original_response: response
                )
              )
            end

            info = json["information"] || {}
            shipment_info = ShipmentInformation.new(
              load_id: info["loadId"],
              pro_number: info["proNumber"],
              billing_id: info["billingId"],
              custom_id: info["customId"],
              po_number: info["poNumber"],
              customer_billing: info["customerBilling"]
            )

            Success(
              ApiResult.new(
                shipment_info,
                original_request: request,
                original_response: response
              )
            )
          end

          private

          # @param json [Hash] the parsed response JSON
          # @return [Array<String>] error messages
          def parse_errors(json)
            messages = json.fetch("messages", [])
            messages.select { |m| m["type"] == "Error" }.map { |m| m["description"] }
          end
        end
      end
    end
  end
end
