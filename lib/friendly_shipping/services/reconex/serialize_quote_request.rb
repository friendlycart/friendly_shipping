# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Serializes a shipment and options into a Reconex quote request hash.
      class SerializeQuoteRequest
        class << self
          # @param shipment [Physical::Shipment] the shipment to serialize
          # @param options [QuoteOptions] the quote options
          # @return [Hash] the serialized request hash
          def call(shipment:, options:)
            {
              mustArriveByDate: options.must_arrive_by_date&.iso8601,
              originLocation: serialize_location(shipment.origin, dock_type: options.dock_type),
              destinationLocation: serialize_location(shipment.destination, dock_type: options.destination_dock_type),
              items: serialize_items(shipment, options),
              totalDetail: {
                quantity: options.total_quantity,
                units: options.total_units
              },
              accessorials: serialize_accessorials(options.accessorials)
            }
          end

          private

          # @param location [Physical::Location] the location to serialize
          # @param options [QuoteOptions] the quote options
          # @return [Hash]
          def serialize_location(location, dock_type:)
            {
              street: location.address1,
              city: location.city,
              state: location.region.code,
              postalCode: location.zip,
              country: location.country.code,
              dockType: dock_type
            }
          end

          # @param shipment [Physical::Shipment] the shipment
          # @param options [QuoteOptions] the quote options
          # @return [Array<Hash>]
          def serialize_items(shipment, options)
            shipment.structures.flat_map do |structure|
              structure_options = options.options_for_structure(structure)
              structure.packages.map do |package|
                package_options = structure_options.options_for_package(package)
                {
                  qty: package.items.count.to_s,
                  packaging: package_options.packaging,
                  freightClass: package_options.freight_class,
                  weight: package.weight.convert_to(:lb).value.to_f.round(2).to_s,
                  nmfCnumber: package_options.nmfc_code,
                  subClass: package_options.sub_class,
                  description: package_options.description,
                  itemDimensions: {
                    length: package.length.convert_to(:in).value.to_f.round.to_i,
                    height: package.height.convert_to(:in).value.to_f.round.to_i,
                    width: package.width.convert_to(:in).value.to_f.round.to_i
                  }
                }
              end
            end
          end

          # Converts snake_case accessorial keys to camelCase.
          # @param accessorials [Hash] the accessorials hash
          # @return [Hash]
          def serialize_accessorials(accessorials)
            accessorials.transform_keys { |key| camelize(key.to_s) }
          end

          # @param str [String] a snake_case string
          # @return [String] the camelCase version
          def camelize(str)
            parts = str.split("_")
            parts[0] + parts[1..].map(&:capitalize).join
          end
        end
      end
    end
  end
end
