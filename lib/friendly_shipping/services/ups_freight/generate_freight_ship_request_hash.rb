# frozen_string_literal: true

require 'friendly_shipping/services/ups_freight/generate_location_hash'
require 'friendly_shipping/services/ups_freight/generate_reference_hash'
require 'friendly_shipping/services/ups_freight/generate_document_options_hash'
require 'friendly_shipping/services/ups_freight/generate_email_options_hash'
require 'friendly_shipping/services/ups_freight/generate_pickup_options_hash'
require 'friendly_shipping/services/ups_freight/generate_delivery_options_hash'

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
                  merge(handling_units(shipment, options).reduce(&:merge).to_h).
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
