# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GenerateFreightShipRequestHash
        class << self
          def call(shipment:, options:)
            {
              FreightShipRequest: {
                Shipment: {
                  ShipperNumber: options.shipper_number,
                  ShipFrom: GenerateLocationHash.call(location: shipment.origin),
                  ShipTo: GenerateLocationHash.call(location: shipment.destination),
                  PaymentInformation: payment_information(options),
                  Service: {
                    Code: options.shipping_method.service_code
                  },
                  Commodity: options.commodity_information_generator.call(shipment: shipment, options: options),
                  Documents: {
                    Image: options.document_options.map { |doc_opts| GenerateDocumentOptionsHash.call(document_options: doc_opts) }
                  },
                  ShipmentServiceOptions: shipment_service_options(options),
                  HandlingInstructions: options.handling_instructions,
                  PickupInstructions: options.pickup_instructions,
                  DeliveryInstructions: options.delivery_instructions,
                  PickupRequest: GeneratePickupRequestHash.call(pickup_request_options: options.pickup_request_options),
                }.compact.
                  merge(GenerateHandlingUnitsHash.call(shipment: shipment, options: options)).
                  merge(GenerateReferenceHash.call(reference_numbers: options.reference_numbers))
              }
            }
          end

          private

          def shipment_service_options(options)
            email_options = options.email_options.map { |email_opts| GenerateEmailOptionsHash.call(email_options: email_opts) }.presence
            pickup_options = options.pickup_options ? GeneratePickupOptionsHash.call(pickup_options: options.pickup_options) : nil
            delivery_options = options.delivery_options ? GenerateDeliveryOptionsHash.call(delivery_options: options.delivery_options) : nil
            [email_options, pickup_options, delivery_options].compact.presence
          end

          def payment_information(options)
            payer_address = GenerateLocationHash.call(location: options.billing_address).
                            merge(ShipperNumber: options.shipper_number)
            {
              Payer: payer_address,
              ShipmentBillingOption: {
                Code: options.billing_code
              }
            }
          end
        end
      end
    end
  end
end
