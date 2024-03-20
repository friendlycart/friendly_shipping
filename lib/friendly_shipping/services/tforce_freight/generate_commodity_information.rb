# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Generates a commodity information hash for JSON serialization.
      class GenerateCommodityInformation
        class << self
          # @param shipment [Physical::Shipment] the shipment with commodities to serialize
          # @param options [#options_for_structure, #options_for_package] the options to serialize
          # @return [Array<Hash>] commodities hash suitable for JSON request
          def call(shipment:, options:)
            if shipment.structures.any?
              serialize_structures(shipment.structures, options)
            else
              warn "[DEPRECATION] `packages` is deprecated.  Please use `structures` instead."
              serialize_packages(shipment.packages, options)
            end
          end

          private

          # @param structures [Array<Physical::Structure>]
          # @param options [#options_for_structure] the options to serialize
          # @return [Array<Hash>]
          def serialize_structures(structures, options)
            structures.flat_map do |structure|
              structure_options = options.options_for_structure(structure)
              structure.packages.map do |package|
                package_options = structure_options.options_for_package(package)
                {
                  description: package.description.presence || "Commodities",
                  class: package_options.freight_class,
                  nmfc: {
                    prime: package_options.nmfc_primary_code,
                    sub: package_options.nmfc_sub_code
                  }.compact.presence,
                  pieces: 1, # We don't support grouping yet
                  weight: {
                    weight: package.weight.convert_to(:pounds).value.to_f.round(2),
                    weightUnit: "LBS"
                  },
                  packagingType: package_options.packaging_code,
                  dangerousGoods: package_options.hazardous,
                  dimensions: {
                    length: package.length.convert_to(:inches).value.to_f.round(2),
                    width: package.width.convert_to(:inches).value.to_f.round(2),
                    height: package.height.convert_to(:inches).value.to_f.round(2),
                    unit: "IN"
                  }
                }.compact
              end
            end
          end

          # @param packages [Array<Physical::Package>]
          # @param options [#options_for_package] the options to serialize
          # @return [Array<Hash>]
          def serialize_packages(packages, options)
            packages.flat_map do |package|
              package_options = options.options_for_package(package)
              package.items.map do |item|
                item_options = package_options.options_for_item(item)
                {
                  description: item.description.presence || "Commodities",
                  class: item_options.freight_class,
                  nmfc: {
                    prime: item_options.nmfc_primary_code,
                    sub: item_options.nmfc_sub_code
                  }.compact.presence,
                  pieces: 1, # We don't support grouping yet
                  weight: {
                    weight: item.weight.convert_to(:pounds).value.to_f.round(2),
                    weightUnit: "LBS"
                  },
                  packagingType: item_options.packaging_code,
                  dangerousGoods: item_options.hazardous,
                  dimensions: {
                    length: item.length.convert_to(:inches).value.to_f.round(2),
                    width: item.width.convert_to(:inches).value.to_f.round(2),
                    height: item.height.convert_to(:inches).value.to_f.round(2),
                    unit: "IN"
                  }
                }.compact
              end
            end
          end
        end
      end
    end
  end
end
