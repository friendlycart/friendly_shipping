# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngineLTL
      class SerializeStructures
        class << self
          # @param structures [Array<Physical::Structure>]
          # @param options [FriendlyShipping::Services::ShipEngineLTL::QuoteOptions]
          # @return [Array<Hash>]
          def call(structures:, options:)
            structures.flat_map do |structure|
              structure_options = options.options_for_structure(structure)
              structure.packages.map do |package|
                package_options = structure_options.options_for_package(package)
                {
                  code: package_options.packaging_code,
                  freight_class: package_options.freight_class,
                  nmfc_code: package_options.nmfc_code,
                  description: package.description || "Commodities",
                  dimensions: {
                    width: package.width.convert_to(:inches).value.ceil,
                    height: package.height.convert_to(:inches).value.ceil,
                    length: package.length.convert_to(:inches).value.ceil,
                    unit: "inches"
                  },
                  weight: {
                    value: package.weight.convert_to(:pounds).value.ceil,
                    unit: "pounds"
                  },
                  quantity: 1, # we don't support this yet
                  stackable: package_options.stackable,
                  hazardous_materials: package_options.hazardous_materials
                }
              end
            end
          end
        end
      end
    end
  end
end
