# frozen_string_literal: true

module FriendlyShipping
  module Services
    class G2Mint
      module REST
        # Options for structures (pallets, skids, etc) in a G2Mint shipment.
        class StructureOptions < FriendlyShipping::StructureOptions
          # Maps friendly names to G2Mint handling unit types.
          HANDLING_UNIT_TYPES = {
            pallet: "PALLET",
            box: "BOX",
            crate: "CRATE",
            carton: "CARTON",
            case: "CASE",
            bag: "BAG",
            bale: "BALE",
            cylinder: "CYLINDER",
            drum: "DRUM",
            reel: "REEL",
            roll: "ROLL",
            pail: "PAIL",
            tank: "TANK",
            tote: "TOTE",
            tube: "TUBE",
            bundle: "BUNDLE"
          }.freeze

          # @return [String] the G2Mint handling unit type code
          attr_reader :handling_unit_type

          # @return [String] the handling unit configuration code
          attr_reader :handling_unit_config_code

          # @param handling_unit [Symbol] the type of handling unit (see {HANDLING_UNIT_TYPES})
          # @param handling_unit_config_code [String] the handling unit configuration code
          # @param kwargs [Hash]
          # @option kwargs [Object] :structure_id unique identifier for this set of options
          # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this structure
          # @option kwargs [Class] :package_options_class the class to use for package options when none are provided
          def initialize(
            handling_unit: :pallet,
            handling_unit_config_code: nil,
            **kwargs
          )
            @handling_unit_type = HANDLING_UNIT_TYPES.fetch(handling_unit)
            @handling_unit_config_code = handling_unit_config_code
            super(**kwargs.reverse_merge(package_options_class: PackageOptions))
          end
        end
      end
    end
  end
end
