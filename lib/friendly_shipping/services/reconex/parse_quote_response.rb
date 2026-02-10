# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Parses a Reconex quote response into an array of Rate objects.
      class ParseQuoteResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the original request
          # @param response [Response] the response to parse
          # @return [Success<ApiResult<Array<Rate>>>, Failure<ApiResult>]
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

            rates = json.fetch("quotes", []).select { |q| q["success"] }.map do |quote|
              shipping_method = FriendlyShipping::ShippingMethod.new(
                name: quote["carrier"],
                service_code: quote["scac"]
              )

              total = Money.new(
                (quote["customerCharge"].to_f * 100).round,
                "USD"
              )

              FriendlyShipping::Rate.new(
                amounts: { total: total },
                shipping_method: shipping_method,
                data: {
                  base: quote["base"],
                  fsc: quote["fsc"],
                  access: quote["access"],
                  transit_time: quote["transitTime"],
                  carrier: quote["carrier"],
                  scac: quote["scac"],
                  notes: quote["notes"]
                }
              )
            end

            Success(
              ApiResult.new(
                rates,
                original_request: request,
                original_response: response
              )
            )
          end

          private

          # @param json [Hash] the parsed response JSON
          # @return [Array<String>] error messages
          def parse_errors(json)
            errors = json.fetch("errors", []).map do |error|
              error.is_a?(Hash) ? error["description"] : error.to_s
            end

            # Check information result code
            info = json["information"]
            if info && info["resultCode"] != "0"
              description = info["resultDescription"]
              errors << description if description
            end

            errors
          end
        end
      end
    end
  end
end
