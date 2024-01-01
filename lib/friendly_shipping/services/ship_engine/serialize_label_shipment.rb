# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      # Serializes a shipment and options for the label API request.
      class SerializeLabelShipment
        class << self
          # @param shipment [Physical::Shipment] the shipment to serialize
          # @param options [LabelOptions] the options to serialize
          # @param test [Boolean] whether to use the test API
          # @return [Hash] the serialized request
          def call(shipment:, options:, test:)
            shipment_hash = {
              label_format: options.label_format,
              label_download_type: options.label_download_type,
              shipment: {
                service_code: options.shipping_method.service_code,
                ship_to: serialize_address(shipment.destination),
                ship_from: serialize_address(shipment.origin),
                packages: serialize_packages(shipment.packages, options)
              }
            }
            # A carrier might not be necessary if the service code is unique within ShipEngine.
            if options.shipping_method.carrier
              shipment_hash[:shipment][:carrier_id] = options.shipping_method.carrier.id
            end

            if international?(shipment)
              shipment_hash[:shipment][:customs] = serialize_customs(shipment.packages, options)
            end

            # Not all carriers support test labels
            if test
              shipment_hash[:test_label] = true
            end

            if options.label_image_id
              shipment_hash[:label_image_id] = options.label_image_id
            end

            shipment_hash
          end

          private

          # @param address [Physical::Location]
          # @return [Hash]
          def serialize_address(address)
            {
              name: address.name,
              phone: address.phone,
              company_name: address.company_name,
              address_line1: address.address1,
              address_line2: address.address2,
              city_locality: address.city,
              state_province: address.region.code,
              postal_code: address.zip,
              country_code: address.country.code
            }.merge(SerializeAddressResidentialIndicator.call(address))
          end

          # @param packages [Array<Physical::Package>]
          # @param options [LabelOptions]
          # @return [Array<Hash>]
          def serialize_packages(packages, options)
            packages.map do |package|
              package_options = options.options_for_package(package)
              package_hash = serialize_weight(package.weight)
              package_hash[:label_messages] = package_options.messages.map.with_index do |message, index|
                [:"reference#{index + 1}", message]
              end.to_h

              package_hash[:package_code] = package_options.package_code
              package_hash[:dimensions] = {
                unit: 'inch',
                width: package.container.width.convert_to(:inches).value.to_f.round(2),
                length: package.container.length.convert_to(:inches).value.to_f.round(2),
                height: package.container.height.convert_to(:inches).value.to_f.round(2)
              }
              package_hash
            end
          end

          # @param packages [Array<Physical::Package>]
          # @param options [LabelOptions]
          def serialize_customs(packages, options)
            {
              contents: options.customs_options.contents,
              non_delivery: options.customs_options.non_delivery,
              customs_items: options.customs_items_serializer.call(packages, options)
            }
          end

          # @param weight [Measured::Weight]
          # @return [Hash]
          def serialize_weight(weight)
            ounces = weight.convert_to(:ounce).value.to_f.round(2)
            {
              weight: {
                # Max weight for USPS First Class is 15.9 oz, not 16 oz
                value: ounces.between?(15.9, 16) ? 15.9 : ounces,
                unit: "ounce"
              }
            }
          end

          # @param shipment [Physical::Shipment]
          # @return [Boolean]
          def international?(shipment)
            shipment.origin.country != shipment.destination.country
          end
        end
      end
    end
  end
end
