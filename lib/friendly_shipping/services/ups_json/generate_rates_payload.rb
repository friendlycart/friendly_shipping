# frozen_string_literal: true

require 'friendly_shipping/services/ups_json/generate_address_hash'
require 'friendly_shipping/services/ups_json/generate_package_hash'

module FriendlyShipping
  module Services
    class UpsJson
      class GenerateRatesPayload
        def self.call(shipment:, options:)
          payload =
            {
              RateRequest: {
                Request: {
                  RequestOption: options.shipping_method.present? ? "Rate" : "Shop",
                  SubVersion: options.sub_version
                },
                PickupType: {
                  Code: options.pickup_type_code
                },
                CustomerClassification: {
                  Code: options.customer_classification_code
                },
                Shipment: {
                  Shipper: GenerateAddressHash.call(location: options.shipper || shipment.origin, international: international?(shipment), shipper_number: options.shipper_number),
                  ShipTo: GenerateAddressHash.call(location: shipment.destination, international: international?(shipment), shipper_number: nil),
                  ShipFrom: GenerateAddressHash.call(location: shipment.origin, international: international?(shipment), shipper_number: nil),
                  PaymentDetails: {
                    ShipmentCharge: [
                      {
                        Type: "01", # Transportation
                        BillShipper: {
                          AccountNumber: options.shipper_number
                        }
                      }
                    # TODO bill third party
                    ]
                  },
                  NumOfPieces: shipment.packages.count
                },
                ShipmentRatingOptions: {
                  NegotiatedRatesIndicator: "2" # Account based rates
                }
              }
            }
          if options.customer_context.present?
            payload[:RateRequest][:Request][:TransactionReference] = { CustomerContext: options.customer_context }
          end

          payload[:RateRequest][:Shipment][:Package] = shipment.packages.map do |package|
            GeneratePackageHash.call(package: package)
          end


          payload
          #     shipper = options.shipper || shipment.origin
          #
          #     xml.Shipment do
          #       if shipper != shipment.origin
          #         xml.ShipFrom do
          #           SerializeAddressSnippet.call(xml: xml, location: shipment.origin)
          #         end
          #       end
          #
          #       if options.pickup_date && options.sub_version.to_i >= 2205
          #         xml.DeliveryTimeInformation do
          #           xml.Pickup do
          #             xml.Date options.pickup_date.strftime('%Y%m%d')
          #             xml.Time options.pickup_date.strftime('%H%M')
          #           end
          #         end
          #       end
          #
          #       shipment.packages.each do |package|
          #         package_options = options.options_for_package(package)
          #         SerializePackageNode.call(
          #           xml: xml,
          #           package: package,
          #           transmit_dimensions: package_options.transmit_dimensions
          #         )
          #       end
          #
          #       if options.shipping_method
          #         xml.Service do
          #           xml.Code options.shipping_method.service_code
          #         end
          #       end
          #
          #       xml.ShipmentServiceOptions do
          #         xml.UPScarbonneutralIndicator if options.carbon_neutral
          #         xml.SaturdayDelivery if options.saturday_delivery
          #         xml.SaturdayPickup if options.saturday_pickup
          #       end
          #
          #       if options.negotiated_rates
          #         xml.RateInformation do
          #           xml.NegotiatedRatesIndicator if options.negotiated_rates
          #         end
          #       end
          #     end
          #   end
          # end
          #
          # xml_builder.to_xml
        end

        def self.international?(shipment)
          shipment.origin.country != shipment.destination.country
        end

      end
    end
  end
end
