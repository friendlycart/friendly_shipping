# frozen_string_literal: true

require 'friendly_shipping/services/ups_freight/generate_location_hash'
require 'friendly_shipping/services/ups_freight/generate_pickup_request_hash'

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
              }.compact.merge(handling_units(shipment, options).reduce(&:merge).to_h)
            }
          end

          private

          def handling_units(shipment, options)
            all_package_options = shipment.packages.map { |package| options.options_for_package(package) }
            all_package_options.group_by(&:handling_unit_code).map do |_handling_unit_code, options_group|
              [options_group.first, options_group.length]
            end.map { |package_options, quantity| handling_unit_hash(package_options, quantity) }
          end

          def handling_unit_hash(package_options, quantity)
            {
              package_options.handling_unit_tag => {
                Quantity: quantity.to_s,
                Type: {
                  Code: package_options.handling_unit_code,
                  Description: package_options.handling_unit_description
                }
              }
            }
          end

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
