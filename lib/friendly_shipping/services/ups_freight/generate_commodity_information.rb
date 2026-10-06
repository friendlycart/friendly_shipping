# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Generates the Commodity array for UPS Freight rate and ship requests.
      class GenerateCommodityInformation
        class << self
          # @param shipment [Physical::Shipment] the shipment to serialize; packages (deprecated) are used if present, otherwise structures
          # @param options [#options_for_package, #options_for_structure] the shipment options
          # @return [Array<Hash>] one commodity hash per item (packages) or per package (structures)
          def call(shipment:, options:)
            if shipment.packages.any?
              warn "[DEPRECATION] `packages` is deprecated.  Please use `structures` instead."
              serialize_packages(shipment.packages, options)
            else
              serialize_structures(shipment.structures, options)
            end
          end

          private

          # @param packages [Array<Physical::Package>]
          # @param options [#options_for_package]
          # @return [Array<Hash>]
          def serialize_packages(packages, options)
            packages.flat_map do |package|
              package_options = options.options_for_package(package)
              package.items.map do |item|
                item_options = package_options.options_for_item(item)
                {
                  # This is a required field
                  Description: item.description || 'Commodities',
                  Weight: {
                    UnitOfMeasurement: {
                      Code: 'LBS' # Only Pounds are supported
                    },
                    Value: item.weight.convert_to(:pounds).value.to_f.round(2).to_s
                  },
                  NumberOfPieces: '1', # We won't support this yet.
                  PackagingType: {
                    Code: item_options.packaging_code
                  },
                  FreightClass: item_options.freight_class
                }
              end
            end
          end

          # @param structures [Array<Physical::Structure>]
          # @param options [#options_for_structure]
          # @return [Array<Hash>]
          def serialize_structures(structures, options)
            structures.flat_map do |structure|
              structure_options = options.options_for_structure(structure)
              structure.packages.map do |package|
                package_options = structure_options.options_for_package(package)
                {
                  # This is a required field
                  Description: package.description || 'Commodities',
                  Weight: {
                    UnitOfMeasurement: {
                      Code: 'LBS' # Only Pounds are supported
                    },
                    Value: package.weight.convert_to(:pounds).value.to_f.round(2).to_s
                  },
                  NumberOfPieces: '1', # We won't support this yet.
                  PackagingType: {
                    Code: package_options.packaging_code
                  },
                  FreightClass: package_options.freight_class
                }
              end
            end
          end
        end
      end
    end
  end
end
