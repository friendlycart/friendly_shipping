# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      class BOLStructuresSerializer
        # @param [Array<Physical::Structure>] structures
        # @param [FriendlyShipping::Services::RL::BOLOptions] options
        # @return [Array<Hash>]
        def self.call(structures:, options:)
          structures.flat_map do |structure|
            structure_options = options.options_for_structure(structure)
            structure.packages.map do |package|
              package_options = structure_options.options_for_package(package)
              {
                IsHazmat: false,
                Pieces: 1,
                PackageType: "BOX",
                NMFCItemNumber: package_options.nmfc_primary_code,
                NMFCSubNumber: package_options.nmfc_sub_code,
                Class: package_options.freight_class,
                Weight: package.weight.convert_to(:pounds).value.ceil,
                Description: package.description.presence || "Commodities"
              }.compact
            end
          end
        end
      end
    end
  end
end
