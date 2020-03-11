# frozen_string_literal: true

require 'friendly_shipping/services/ups_freight/parse_shipment_document'
require 'friendly_shipping/services/ups_freight/shipment_information'

module FriendlyShipping
  module Services
    class UpsFreight
      class ParseFreightLabelResponse
        class << self
          def call(request:, response:)
            json = JSON.parse(response.body)

            warnings_json = Array.wrap(json.dig("FreightShipResponse", "Response", "Alert"))
            warnings = warnings_json.map do |detailed_warning|
              status = detailed_warning['Code']
              desc = detailed_warning['Description']
              [status, desc].compact.join(": ")
            end.join("\n")

            shipment_results = json.dig("FreightShipResponse", "ShipmentResults")

            service_code = shipment_results.dig("Service", "Code")
            shipping_method = SHIPPING_METHODS.detect { |sm| sm.service_code == service_code }

            total_shipment_charge = shipment_results.dig("TotalShipmentCharge")
            currency = Money::Currency.new(total_shipment_charge['CurrencyCode'])
            amount = total_shipment_charge['MonetaryValue'].to_f
            total_money = Money.new(amount * currency.subunit_to_unit, currency)

            images_data = Array.wrap(shipment_results.dig("Documents", "Image"))

            bol_id = shipment_results.dig("BOLID")
            shipment_number = shipment_results.dig("ShipmentNumber")
            pickup_request_number = shipment_results.dig("PickupRequestConfirmationNumber")

            documents = images_data.map { |image_data| ParseShipmentDocument.call(image_data: image_data) }

            FriendlyShipping::ApiResult.new(
              ShipmentInformation.new(
                total: total_money,
                bol_id: bol_id,
                number: shipment_number,
                pickup_request_number: pickup_request_number,
                shipping_method: shipping_method,
                warnings: warnings,
                documents: documents
              ),
              original_request: request,
              original_response: response
            )
          end
        end
      end
    end
  end
end
