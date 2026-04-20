# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      class StructureOptions < FriendlyShipping::StructureOptions
        # Maps friendly names to R+L handling unit types.
        HANDLING_UNIT_TYPES = {
          skid: "SKD",
          box: "BOX",
          bag: "BAG",
          bar: "BAR",
          bin: "BIN",
          bundle: "BNDL",
          unit: "UNIT",
          basket: "BSKT",
          bulk: "BULK",
          carboy: "CARBOY",
          coil: "COIL",
          crate: "CRT",
          carton: "CTN",
          cylinder: "CYL",
          drum: "DRM",
          gaylord: "GAY",
          ibc: "IBC",
          jerrycan: "JER",
          loose: "LSE",
          multi_bag: "MLBG",
          non_standard: "NSTD",
          pail: "PAIL",
          piggyback: "PIG",
          pallet: "PLT",
          rack: "RACK",
          reel: "REEL",
          roll: "ROLL",
          stack: "STK",
          truckload: "TL",
          tank: "TANK",
          tote: "TOTE",
          cpt: "CPT",
          dac: "DAC"
        }.freeze

        # @return [String] the R+L handling unit code (e.g., "PLT", "SKD")
        attr_reader :handling_unit_code

        # @param handling_unit [Symbol] how this shipment is divided (see {HANDLING_UNIT_TYPES})
        # @param kwargs [Hash]
        # @option kwargs [Object] :structure_id unique identifier for this set of options
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this structure
        # @option kwargs [Class] :package_options_class the class to use for package options when none are provided
        def initialize(handling_unit: :pallet, **kwargs)
          @handling_unit_code = HANDLING_UNIT_TYPES.fetch(handling_unit)
          super(**kwargs.reverse_merge(package_options_class: PackageOptions))
        end
      end
    end
  end
end
