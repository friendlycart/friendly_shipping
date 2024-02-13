# frozen_string_literal: true

require 'friendly_shipping/rate'
require 'friendly_shipping/api_result'
require 'friendly_shipping/services/tforce_freight/shipping_methods'

module FriendlyShipping
  module Services
    class TForceFreight
      # Parse a TForce Freight BOL response JSON into an ApiResult.
      class ParseCreateBOLResponse
        class << self
          # @param request [Request] the original request
          # @param response [RestClient::Response] the response to parse
          # @return [ApiResult<Hash>] the parsed result
          def call(request:, response:)
            json = JSON.parse(response.body)

            bol_id = json.dig("detail", "bolId")
            pro_number = json.dig("detail", "pro")

            rate_detail = json.dig("detail", "rateDetail")&.first
            if rate_detail
              service_code = rate_detail.dig("service", "code")
              shipping_method = SHIPPING_METHODS.detect { |sm| sm.service_code == service_code }

              rates = rate_detail["rate"].each_with_object({}) do |rate, result|
                result[rate["code"].downcase.to_sym] = rate["value"].to_f
              end

              total_charges_value = rate_detail.dig("shipmentCharges", "total", "value")
              total_charges_currency = rate_detail.dig("shipmentCharges", "total", "currency")
              total_charges = Money.new(total_charges_value.to_f * 100, total_charges_currency || "USD")

              billable_weight_value = rate_detail.dig("shipmentWeights", "billable", "value")
              billable_weight_unit = rate_detail.dig("shipmentWeights", "billable", "unit")
              billable_weight = Measured::Weight(billable_weight_value, billable_weight_unit&.downcase || :lb)

              days_in_transit = rate_detail.dig("timeInTransit", "timeInTransit")&.to_i
              cost_breakdown = build_cost_breakdown(rate_detail)
            end

            origin_service_center = json.dig("detail", "originServiceCenter")
            email_sent = json.dig("detail", "pickup", "emailSent") == "true"
            origin_is_rural = json.dig("detail", "pickup", "originIsRural") == "true"
            destination_is_rural = json.dig("detail", "pickup", "destinationIsRural") == "true"

            documents = json.dig("detail", "documents", "image")&.map do |image_data|
              ParseShipmentDocument.call(image_data: image_data)
            end

            FriendlyShipping::ApiResult.new(
              ShipmentInformation.new(
                bol_id: bol_id,
                pro_number: pro_number,
                origin_service_center: origin_service_center,
                email_sent: email_sent,
                origin_is_rural: origin_is_rural,
                destination_is_rural: destination_is_rural,
                rates: rates,
                total_charges: total_charges,
                billable_weight: billable_weight,
                days_in_transit: days_in_transit,
                shipping_method: shipping_method,
                documents: documents,
                data: {
                  cost_breakdown: cost_breakdown
                }
              ),
              original_request: request,
              original_response: response
            )
          end

          private

          def build_cost_breakdown(rate_detail)
            {
              "Rates" => rate_detail["rate"].each_with_object({}) do |rate, hash|
                hash[rate["code"]] = rate["value"]
              end,
              "TotalShipmentCharge" => rate_detail.dig("shipmentCharges", "total", "value"),
              "BillableShipmentWeight" => rate_detail.dig("shipmentWeights", "billable", "value")
            }.compact
          end
        end
      end
    end
  end
end
