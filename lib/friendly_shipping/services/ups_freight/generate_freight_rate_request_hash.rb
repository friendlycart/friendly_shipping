# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Generates the FreightRateRequest hash for UPS Freight rate requests.
      class GenerateFreightRateRequestHash
        class << self
          # @param shipment [Physical::Shipment] the shipment to rate
          # @param options [RatesOptions] the rating options
          # @return [Hash] the request hash
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

          # @param customer_context [String, nil] a reference to match the request with an order or shipment
          # @return [Hash] the Request hash, empty if there is no customer context
          def request_options(customer_context)
            return {} unless customer_context

            {
              TransactionReference: {
                CustomerContext: customer_context
              }
            }
          end

          # @param options [RatesOptions] the rating options
          # @return [Hash] the payer and billing option hash
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
