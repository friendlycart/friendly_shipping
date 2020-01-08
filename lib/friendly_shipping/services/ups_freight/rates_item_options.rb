# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Options for Items in a UPS Freight shipment
      #
      # @attribute [Symbol] packaging How the item is packaged, one of the keys of `PACKAGING_TYPES`
      # @attribute [String] freight_class The freight class of this item, for example '55' or '92.5'
      # @attribute [String] nmfc_code The national motor freight corporation code for this item. Something like '13050 sub 4'
      class RatesItemOptions < FriendlyShipping::ItemOptions
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

        attr_reader :packaging_code,
                    :packaging_description,
                    :freight_class,
                    :nmfc_code

        def initialize(
          packaging: :carton,
          freight_class: nil,
          nmfc_code: nil,
          **kwargs
        )
          @packaging_code = PACKAGING_TYPES.fetch(packaging).fetch(:code)
          @packaging_description = PACKAGING_TYPES.fetch(packaging).fetch(:description)
          @freight_class = freight_class
          @nmfc_code = nmfc_code
          super(**kwargs)
        end
      end
    end
  end
end
