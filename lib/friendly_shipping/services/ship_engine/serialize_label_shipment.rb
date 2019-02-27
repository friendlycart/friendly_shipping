module FriendlyShipping
  module Services
    class ShipEngine
      class SerializeLabelShipment
        attr_reader :shipment

        def initialize(shipment:)
          @shipment = shipment
        end

        def call
          {
            label_format: shipment.options[:label_format].presence || "pdf",
            shipment: {
              service_code: shipment.service_code,
              ship_to: serialize_address(shipment.destination),
              ship_from: serialize_address(shipment.origin),
              packages: serialize_packages(shipment.packages)
            }
          }
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
            package_hash = {
              weight: {
                value: package.weight.convert_to(:ounce).value.to_f,
                unit: "ounce"
              }
            }
            if package.container.properties[:usps_package_code]
              package_hash.merge!(package_code: package.container.properties[:usps_package_code])
            end
            package_hash
          end
        end
      end
    end
  end
end
