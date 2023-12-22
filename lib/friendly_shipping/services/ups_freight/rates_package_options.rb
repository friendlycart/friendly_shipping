# frozen_string_literal: true

require 'friendly_shipping/services/ups_freight/rates_item_options'

module FriendlyShipping
  module Services
    class UpsFreight
      # Options for packages/pallets within a UPS Freight shipment.
      class RatesPackageOptions < FriendlyShipping::PackageOptions
        # Maps friendly names to packaging types.
        PACKAGING_TYPES = {
          bag: { code: "BAG", description: "Bag" },
          bale: { code: "BAL", description: "Bale" },
          barrel: { code: "BAR", description: "Barrel" },
          bundle: { code: "BDL", description: "Bundle" },
          bin: { code: "BIN", description: "Bin" },
          box: { code: "BOX", description: "Box" },
          basket: { code: "BSK", description: "Basket" },
          bunch: { code: "BUN", description: "Bunch" },
          cabinet: { code: "CAB", description: "Cabinet" },
          can: { code: "CAN", description: "Can" },
          carrier: { code: "CAR", description: "Carrier" },
          case: { code: "CAS", description: "Case" },
          carboy: { code: "CBY", description: "Carboy" },
          container: { code: "CON", description: "Container" },
          crate: { code: "CRT", description: "Crate" },
          cask: { code: "CSK", description: "Cask" },
          carton: { code: "CTN", description: "Carton" },
          cylinder: { code: "CYL", description: "Cylinder" },
          drum: { code: "DRM", description: "Drum" },
          loose: { code: "LOO", description: "Loose" },
          other: { code: "OTH", description: "Other" },
          pail: { code: "PAL", description: "Pail" },
          pieces: { code: "PCS", description: "Pieces" },
          package: { code: "PKG", description: "Package" },
          pipe_line: { code: "PLN", description: "Pipe Line" },
          pallet: { code: "PLT", description: "Pallet" },
          rack: { code: "RCK", description: "Rack" },
          reel: { code: "REL", description: "Reel" },
          roll: { code: "ROL", description: "Roll" },
          skid: { code: "SKD", description: "Skid" },
          spool: { code: "SPL", description: "Spool" },
          tube: { code: "TBE", description: "Tube" },
          tank: { code: "TNK", description: "Tank" },
          totes: { code: "TOT", description: "Totes" },
          unit: { code: "UNT", description: "Unit" },
          van_pack: { code: "VPK", description: "Van Pack" },
          wrapped: { code: "WRP", description: "Wrapped" }
        }.freeze

        # Maps friendly names to handling unit types.
        HANDLING_UNIT_TYPES = {
          pallet: { code: "PLT", description: "Pallet", handling_unit_tag: 'One' },
          skid: { code: "SKD", description: "Skid", handling_unit_tag: 'One' },
          carboy: { code: "CBY", description: "Carboy", handling_unit_tag: 'One' },
          totes: { code: "TOT", description: "Totes", handling_unit_tag: 'One' },
          other: { code: "OTH", description: "Other", handling_unit_tag: 'Two' },
          loose: { code: "LOO", description: "Loose", handling_unit_tag: 'Two' }
        }.freeze

        # @return [String]
        attr_reader :packaging_code

        # @return [String]
        attr_reader :packaging_description

        # @return [String]
        attr_reader :freight_class

        # @return [String]
        attr_reader :nmfc_code

        # @return [String]
        attr_reader :handling_unit_description

        # @return [String]
        attr_reader :handling_unit_tag

        # @return [String]
        attr_reader :handling_unit_code

        # @param packaging [Symbol] how this shipment is packaged (see {PACKAGING_TYPES})
        # @param freight_class [String] the freight class
        # @param nmfc_code [String] the NMFC code
        # @param handling_unit [Symbol] how this shipment is divided (see {HANDLING_UNIT_TYPES})
        # @param kwargs [Hash]
        # @option kwargs [String] :package_id the ID for the package  that belongs to these options
        # @option kwargs [Array<ItemOptions>] :item_options the options for items in this package
        # @option kwargs [Class] :item_options_class the class to use for item options when none are provided
        def initialize(
          packaging: :carton,
          freight_class: nil,
          nmfc_code: nil,
          handling_unit: :pallet,
          **kwargs
        )
          @packaging_code = PACKAGING_TYPES.fetch(packaging).fetch(:code)
          @packaging_description = PACKAGING_TYPES.fetch(packaging).fetch(:description)
          @freight_class = freight_class
          @nmfc_code = nmfc_code
          @handling_unit_code = HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:code)
          @handling_unit_description = HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:description)
          @handling_unit_tag = "HandlingUnit#{HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:handling_unit_tag)}"
          super(**kwargs.reverse_merge(item_options_class: RatesItemOptions))
        end
      end
    end
  end
end
