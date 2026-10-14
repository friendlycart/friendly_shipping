# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Item properties relevant for generating a UPS shipping label, used for international forms.
      # @option commodity_code [String] this item's commodity code
      # @option country_of_origin [String] this item's country of origin
      # @option product_unit_of_measure [Symbol] a key from PRODUCT_UNIT_OF_MEASURE_CODES. Default: `:number`
      class LabelItemOptions < FriendlyShipping::ItemOptions
        # Maps unit of measure names to UPS product unit of measure codes.
        PRODUCT_UNIT_OF_MEASURE_CODES = {
          barrel: 'BA',
          bundle: 'BE',
          bag: 'BG',
          bunch: 'BH',
          box: 'BOX',
          bolt: 'BT',
          butt: 'BU',
          canister: 'CI',
          centimeter: 'CM',
          container: 'CON',
          crate: 'CR',
          case: 'CS',
          carton: 'CT',
          cylinder: 'CY',
          dozen: 'DOZ',
          each: 'EA',
          envelope: 'EN',
          feet: 'FT',
          kilogram: 'KG',
          kilograms: 'KGS',
          pound: 'LB',
          pounds: 'LBS',
          liter: 'L',
          meter: 'M',
          number: 'NMB',
          packet: 'PA',
          pallet: 'PAL',
          piece: 'PC',
          pieces: 'PCS',
          proof_liters: 'PF',
          package: 'PKG',
          pair: 'PR',
          pairs: 'PRS',
          roll: 'RL',
          set: 'SET',
          square_meters: 'SME',
          square_yards: 'SYD',
          tube: 'TU',
          yard: 'YD',
          other: 'OTH'
        }.freeze

        attr_reader :commodity_code,
                    :country_of_origin

        def initialize(
          commodity_code: nil,
          country_of_origin: nil,
          product_unit_of_measure: :number,
          **kwargs
        )
          @commodity_code = commodity_code
          @country_of_origin = country_of_origin
          @product_unit_of_measure = product_unit_of_measure
          super(**kwargs)
        end

        # @return [String, nil] the UPS code for the product unit of measure, or nil if it is not a known key
        def product_unit_of_measure_code
          PRODUCT_UNIT_OF_MEASURE_CODES[product_unit_of_measure]
        end

        private

        attr_reader :product_unit_of_measure
      end
    end
  end
end
