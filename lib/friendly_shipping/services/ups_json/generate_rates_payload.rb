# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class GenerateRatesPayload
        def self.call(shipment:, options:)
          payload =
            {
              RateRequest: {
                PickupType: {
                  Code: options.pickup_type_code
                },
                CustomerClassification: {
                  Code: options.customer_classification_code
                },
                Shipment: {
                  Shipper: GenerateAddressHash.call(location: options.shipper || shipment.origin, international: international?(shipment), shipper_number: options.shipper_number),
                  ShipTo: GenerateAddressHash.call(location: shipment.destination, international: international?(shipment)),
                  ShipFrom: GenerateAddressHash.call(location: shipment.origin),
                  PaymentDetails: {
                    ShipmentCharge: [
                      {
                        Type: "01", # Transportation
                        BillShipper: {
                          AccountNumber: options.shipper_number
                        }
                      }
                    ]
                  },
                  NumOfPieces: shipment.packages.count
                }
              }
            }

          if options.customer_context.present?
            payload[:RateRequest][:Request] = { TransactionReference: { CustomerContext: options.customer_context } }
          end

          payload[:RateRequest][:Shipment][:Package] = shipment.packages.map do |package|
            package_options = options.options_for_package(package)
            transmit_dimensions = package_options.transmit_dimensions || false
            GeneratePackageHash.call(
              package: package,
              package_flavor: 'rates',
              transmit_dimensions: transmit_dimensions
            )
          end

          if options.pickup_date && options.sub_version.to_i >= 2205
            payload[:RateRequest][:Shipment][:DeliveryTimeInformation] = {
              PackageBillType: "03", # Non-document
              Pickup: {
                Date: options.pickup_date.strftime('%Y%m%d'),
                Time: options.pickup_date.strftime('%H%M%S')
              }
            }
          end

          if options.shipping_method
            payload[:RateRequest][:Shipment][:Service] = { Code: options.shipping_method.service_code }
          end

          payload[:RateRequest][:Shipment][:ShipmentServiceOptions] = {
            UPScarbonneutralIndicator: options.carbon_neutral,
            SaturdayDelivery: options.saturday_delivery,
            SaturdayPickup: options.saturday_pickup
          }.compact

          if options.negotiated_rates
            payload[:RateRequest][:Shipment][:ShipmentRatingOptions] ||= {}
            payload[:RateRequest][:Shipment][:ShipmentRatingOptions][:NegotiatedRatesIndicator] = "X"
          end

          payload
        end

        def self.international?(shipment)
          shipment.origin.country != shipment.destination.country
        end
      end
    end
  end
end
