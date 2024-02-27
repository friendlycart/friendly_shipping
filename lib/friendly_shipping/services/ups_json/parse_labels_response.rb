# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class ParseLabelsResponse
        class << self
          def call(request:, response:)
            parsed_response = ParseJsonResponse.call(
              request: request,
              response: response,
              expected_root_key: 'ShipmentResponse'
            )
            parsed_response.fmap do |parsing_result|
              FriendlyShipping::ApiResult.new(
                build_labels(parsing_result),
                original_request: request,
                original_response: response
              )
            end
          end

          def build_labels(labels_result)
            shipment_result = labels_result["ShipmentResponse"]["ShipmentResults"]

            Array.wrap(shipment_result["PackageResults"]).map do |package|
              cost_breakdown = build_cost_breakdown(package)
              package_cost = cost_breakdown.values.any? ? cost_breakdown.values.sum : nil

              FriendlyShipping::Services::UpsJson::Label.new(
                shipment_id: shipment_result["ShipmentIdentificationNumber"],
                tracking_number: package["TrackingNumber"],
                usps_tracking_number: package["USPSPICNumber"],
                label_data: Base64.decode64(package["ShippingLabel"]["GraphicImage"]),
                label_format: package["ShippingLabel"]["ImageFormat"]["Code"],
                label_href: package["LabelURL"],
                cost: package_cost,
                shipment_cost: get_shipment_cost(shipment_result),
                data: {
                  cost_breakdown: cost_breakdown,
                  negotiated_rate: get_negotiated_rate(shipment_result),
                  customer_context: labels_result["ShipmentResponse"]["Response"]["TransactionReference"]["CustomerContext"]
                }.compact
              )
            end
          end

          def build_cost_breakdown(package)
            costs = [
              package["BaseServiceCharge"],
              Array.wrap(package["ServiceOptionsCharges"]),
              Array.wrap(package["ItemizedCharges"])
            ].flatten

            costs.map { |cost| ParseMoneyHash.call(cost, "UnknownSurcharge") }.compact.to_h
          end

          def get_shipment_cost(shipment_result)
            total_charges_hash = shipment_result.dig("ShipmentCharges", "TotalCharges")
            ParseMoneyHash.call(total_charges_hash, "TotalCharges")&.last
          end

          def get_negotiated_rate(shipment_result)
            negotiated_total_hash = shipment_result.dig("NegotiatedRateCharges", "TotalCharge")
            ParseMoneyHash.call(negotiated_total_hash, "TotalCharge")&.last
          end
        end
      end
    end
  end
end
