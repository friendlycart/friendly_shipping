# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Serializes handling units for R+L BOL API requests. Each {Physical::Structure}
      # in the shipment becomes one HandlingUnit with its container dimensions and
      # the packages it contains serialized as nested Items.
      class BOLHandlingUnitsSerializer
        # @param structures [Array<Physical::Structure>] the structures to serialize
        # @param options [BOLOptions] options for the serialization
        # @return [Array<Hash>] the serialized handling units
        def self.call(structures:, options:)
          structures.map do |structure|
            structure_options = options.options_for_structure(structure)
            {
              UnitType: structure_options.handling_unit_code,
              Dimensions: dimensions(structure),
              Items: items(structure, structure_options)
            }.compact
          end
        end

        # @param structure [Physical::Structure]
        # @return [Array<Hash>, nil] dimensions array or nil if any dimension is zero/infinite
        def self.dimensions(structure)
          values = structure.dimensions.map(&:value)
          return if values.any? { |v| v.zero? || v.infinite? }

          [{
            Count: 1,
            Length: structure.length.convert_to(:inches).value.to_f.round(2).to_s,
            Width: structure.width.convert_to(:inches).value.to_f.round(2).to_s,
            Height: structure.height.convert_to(:inches).value.to_f.round(2).to_s
          }]
        end
        private_class_method :dimensions

        # @param structure [Physical::Structure]
        # @param structure_options [StructureOptions]
        # @return [Array<Hash>]
        def self.items(structure, structure_options)
          groups = structure.packages.group_by do |package|
            package_options = structure_options.options_for_package(package)
            [
              package.description.presence || "Commodities",
              package_options.freight_class,
              package_options.nmfc_primary_code,
              package_options.nmfc_sub_code
            ]
          end

          groups.map do |(description, freight_class, nmfc_primary_code, nmfc_sub_code), packages|
            weight = packages.sum { |package| package.weight.convert_to(:pounds).value }.ceil
            {
              IsHazmat: false,
              Pieces: packages.size,
              PackageType: "BOX",
              NMFCItemNumber: nmfc_primary_code,
              NMFCSubNumber: nmfc_sub_code,
              Class: freight_class,
              Weight: weight,
              Description: description
            }.compact
          end
        end
        private_class_method :items
      end
    end
  end
end
