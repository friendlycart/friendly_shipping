# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Options for items in a shipment.
      class ItemOptions < FriendlyShipping::ItemOptions
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

        # @param packaging [Symbol] this item's packaging
        # @param freight_class [String] the freight class
        # @param nmfc_primary_code [String] the NMFC primary code
        # @param nmfc_sub_code [String] the NMFC sub code
        # @param hazardous [Boolean] whether or not the item is hazardous
        # @param kwargs [Hash]
        # @option kwargs [String] :item_id the ID for the item that belongs to these options
        def initialize(
          packaging: :carton,
          freight_class: nil,
          nmfc_primary_code: nil,
          nmfc_sub_code: nil,
          hazardous: false,
          **kwargs
        )
          @packaging_code = PACKAGING_TYPES.fetch(packaging).fetch(:code)
          @packaging_description = PACKAGING_TYPES.fetch(packaging).fetch(:description)
          @freight_class = freight_class
          @nmfc_primary_code = nmfc_primary_code
          @nmfc_sub_code = nmfc_sub_code
          @hazardous = hazardous
          super(**kwargs)
        end
      end
    end
  end
end
