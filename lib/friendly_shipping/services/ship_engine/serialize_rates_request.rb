# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      # Serializes a shipment and options for the rates API request.
      class SerializeRatesRequest
        class << self
          # @param shipment [Physical::Shipment] the shipment to serialize
          # @param options [LabelOptions] the options to serialize
          # @return [Hash] the serialized request
          def call(shipment:, options:)
            rates_hash = {
              shipment: {
                carrier_ids: options.carrier_ids,
                service_code: options.service_code,
                ship_date: options.ship_date.strftime('%Y-%m-%d'),
                ship_to: serialize_address(shipment.destination),
                ship_from: serialize_address(shipment.origin),
                items: serialize_items(shipment.packages.first),
                packages: serialize_packages(shipment, options),
                comparison_rate_type: options.comparison_rate_type,
                confirmation: 'none'
              }.merge(SerializeAddressResidentialIndicator.call(shipment.destination)).compact_blank,
              rate_options: {
                carrier_ids: options.carrier_ids,
                service_codes: [options.service_code],
              }
            }

            if international?(shipment)
              rates_hash[:shipment][:customs] = {
                contents: "merchandise",
                non_delivery: "return_to_sender",
              }
            end

            rates_hash
          end

          private

          # @param package [Physical::Package]
          # @return [Array<Hash>]
          def serialize_items(package)
            return [] unless package&.items.present?

            package.items.group_by(&:sku).map do |sku, items|
              reference_item = items.first
              {
                name: reference_item.description,
                sku: sku,
                quantity: items.size
              }
            end
          end

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

          # @param shipment [Physical::Shipment]
          # @param options [LabelOptions]
          # @return [Array<Hash>]
          def serialize_packages(shipment, options)
            shipment.packages.map do |package|
              {
                weight: {
                  value: package.weight.convert_to(:pound).value.to_f.round(2),
                  unit: 'pound'
                },
                dimensions: {
                  unit: 'inch',
                  length: package.length.convert_to(:inch).value.to_f.round(2),
                  width: package.width.convert_to(:inch).value.to_f.round(2),
                  height: package.height.convert_to(:inch).value.to_f.round(2)
                },
                products: serialize_products(package, options),
              }
            end
          end

          # @param package [Physical::Package]
          # @param options [LabelOptions]
          # @return [Array<Hash>]
          def serialize_products(package, options)
            package.items.group_by(&:sku).map do |sku, items|
              reference_item = items.first
              package_options = options.options_for_package(package)
              item_options = package_options.options_for_item(reference_item)
              {
                sku: sku,
                description: reference_item.description,
                quantity: items.count,
                value: {
                  amount: reference_item.cost.to_d,
                  currency: reference_item.cost.currency.to_s
                },
                harmonized_tariff_code: item_options.commodity_code,
                country_of_origin: item_options.country_of_origin
              }
            end
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
