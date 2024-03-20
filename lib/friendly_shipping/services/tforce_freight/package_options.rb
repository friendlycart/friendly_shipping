# frozen_string_literal: true

require 'friendly_shipping/services/tforce_freight/rates_item_options'

module FriendlyShipping
  module Services
    class TForceFreight
      # Options for packages/pallets in a shipment.
      class PackageOptions < FriendlyShipping::PackageOptions
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

        # @return [Symbol] the code for this item's packaging
        attr_reader :packaging_code

        # @return [String] the description for this item's packaging
        attr_reader :packaging_description

        # @return [String] the freight class
        attr_reader :freight_class

        # @return [String] the NMFC primary code
        attr_reader :nmfc_primary_code

        # @return [String] the NMFC sub code
        attr_reader :nmfc_sub_code

        # @return [Boolean] whether or not the item is hazardous
        attr_reader :hazardous

        # @return [String] the handling unit description
        attr_reader :handling_unit_description

        # @return [String] the handling unit tag
        attr_reader :handling_unit_tag

        # @return [String] the handling unit code
        attr_reader :handling_unit_code

        # @param packaging [Symbol] this item's packaging
        # @param freight_class [String] the freight class
        # @param nmfc_primary_code [String] the NMFC primary code
        # @param nmfc_sub_code [String] the NMFC sub code
        # @param hazardous [Boolean] whether or not the item is hazardous
        # @param handling_unit [Symbol] the handling unit for this package/pallet
        # @param kwargs [Hash]
        # @option kwargs [String] :package_id the ID for the package  that belongs to these options
        # @option kwargs [Array<ItemOptions>] :item_options the options for items in this package
        # @option kwargs [Class] :item_options_class the class to use for item options when none are provided
        def initialize(
          packaging: :carton,
          freight_class: nil,
          nmfc_primary_code: nil,
          nmfc_sub_code: nil,
          hazardous: false,
          handling_unit: :pallet,
          **kwargs
        )
          @packaging_code = PACKAGING_TYPES.fetch(packaging).fetch(:code)
          @packaging_description = PACKAGING_TYPES.fetch(packaging).fetch(:description)
          @freight_class = freight_class
          @nmfc_primary_code = nmfc_primary_code
          @nmfc_sub_code = nmfc_sub_code
          @hazardous = hazardous
          @handling_unit_code = HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:code)
          @handling_unit_description = HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:description)
          @handling_unit_tag = "handlingUnit#{HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:handling_unit_tag)}"
          super(**kwargs.reverse_merge(item_options_class: ItemOptions))
        end
      end
    end
  end
end
