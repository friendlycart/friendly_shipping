# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      class SerializeLabelShipment
        class << self
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

            if test
              shipment_hash[:test_label] = true
            end

            if options.label_image_id
              shipment_hash[:label_image_id] = options.label_image_id
            end

            shipment_hash
          end

          private

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
              country_code: address.country.code,
              address_residential_indicator: "No"
            }
          end

          def serialize_packages(packages, options)
            packages.map do |package|
              package_options = options.options_for_package(package)
              package_hash = serialize_weight(package.weight)
              package_hash[:label_messages] = package_options.messages.map.with_index do |message, index|
                ["reference#{index + 1}".to_sym, message]
              end.to_h

              if package_options.package_code
                package_hash[:package_code] = package_options.package_code
              else
                package_hash[:dimensions] = {
                  unit: 'inch',
                  width: package.container.width.convert_to(:inches).value.to_f.round(2),
                  length: package.container.length.convert_to(:inches).value.to_f.round(2),
                  height: package.container.height.convert_to(:inches).value.to_f.round(2)
                }
              end
              package_hash
            end
          end

          def serialize_weight(weight)
            ounces = weight.convert_to(:ounce).value.to_f
            {
              weight: {
                # Max weight for USPS First Class is 15.9 oz, not 16 oz
                value: ounces.between?(15.9, 16) ? 15.9 : ounces,
                unit: "ounce"
              }
            }
          end
        end
      end
    end
  end
end
