# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      class SerializeLabelShipment
        class << self
          def call(shipment:, shipping_method:, test:)
            shipment_hash = {
              label_format: shipment.options[:label_format].presence || "pdf",
              label_download_type: shipment.options[:label_download_type].presence || "url",
              shipment: {
                service_code: shipping_method.service_code,
                ship_to: serialize_address(shipment.destination),
                ship_from: serialize_address(shipment.origin),
                packages: serialize_packages(shipment.packages)
              }
            }
            # A carrier might not be necessary if the service code is unique within ShipEngine.
            if shipping_method.carrier
              shipment_hash[:shipment][:carrier_id] = shipping_method.carrier.id
            end

            if test
              shipment_hash[:test] = true
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

          def serialize_packages(packages)
            packages.map do |package|
              package_hash = serialize_weight(package.weight)
              if package.container.properties[:usps_label_messages]
                package_hash[:label_messages] = package.container.properties[:usps_label_messages]
              end
              package_code = package.container.properties[:usps_package_code]
              if package_code
                package_hash[:package_code] = package_code
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
