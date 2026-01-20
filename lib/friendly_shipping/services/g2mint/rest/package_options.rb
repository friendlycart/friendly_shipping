# frozen_string_literal: true

module FriendlyShipping
  module Services
    class G2Mint
      module REST
        # Options for a package within a G2Mint shipment.
        class PackageOptions < FriendlyShipping::PackageOptions
          # Maps friendly names to G2Mint packaging unit types.
          PACKAGING_UNIT_TYPES = {
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

          # @return [String] freight class (e.g., "50", "55", "60", "65", "70", "77.5", "85", "92.5", "100", "110", "125", "150", "175", "200", "250", "300", "400", "500")
          attr_reader :freight_class

          # @return [String] NMFC code (National Motor Freight Classification)
          attr_reader :nmfc

          # @return [Boolean] whether the commodity is hazardous material
          attr_reader :is_hazmat

          # @return [String] product code
          attr_reader :product_code

          # @return [String] packaging configuration code
          attr_reader :packaging_config_code

          # @return [String] the G2Mint packaging unit type code
          attr_reader :packaging_unit_type

          # @param freight_class [String] freight class
          # @param nmfc [String] NMFC code
          # @param is_hazmat [Boolean] whether the commodity is hazardous material
          # @param product_code [String] product code
          # @param packaging_config_code [String] packaging configuration code
          # @param packaging_unit [Symbol] the type of packaging unit (see {PACKAGING_UNIT_TYPES})
          # @param kwargs [Hash]
          def initialize(
            freight_class: "50",
            nmfc: nil,
            is_hazmat: false,
            product_code: nil,
            packaging_config_code: nil,
            packaging_unit: nil,
            **kwargs
          )
            @freight_class = freight_class
            @nmfc = nmfc
            @is_hazmat = is_hazmat
            @product_code = product_code
            @packaging_config_code = packaging_config_code
            @packaging_unit_type = packaging_unit ? PACKAGING_UNIT_TYPES.fetch(packaging_unit) : nil

            super(**kwargs)
          end
        end
      end
    end
  end
end
