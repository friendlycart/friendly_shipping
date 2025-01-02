# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GenerateFreightRateRequestHash
        class << self
          def call(shipment:, options:)
            {
              FreightRateRequest: {
                Request: request_options(options.customer_context),
                ShipperNumber: options.shipper_number,
                ShipFrom: GenerateLocationHash.call(location: shipment.origin),
                ShipTo: GenerateLocationHash.call(location: shipment.destination),
                PaymentInformation: payment_information(options),
                Service: {
                  Code: options.shipping_method.service_code
                },
                Commodity: options.commodity_information_generator.call(shipment: shipment, options: options),
                TimeInTransitIndicator: 'true',
                PickupRequest: GeneratePickupRequestHash.call(pickup_request_options: options.pickup_request_options),
              }.compact.
                merge(GenerateHandlingUnitsHash.call(shipment: shipment, options: options))
            }
          end

          private

          def request_options(customer_context)
            return {} unless customer_context

            {
              TransactionReference: {
                CustomerContext: customer_context
              }
            }
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
