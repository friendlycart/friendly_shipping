# frozen_string_literal: true

require 'friendly_shipping/services/ups/rate_estimate_package_options'

module FriendlyShipping
  module Services
    class USPSShip
      class RateEstimatePackageOptions < FriendlyShipping::PackageOptions
        PROCESSING_CATEGORIES = {
          letters: "LETTERS",
          flats: "FLATS",
          machinable: "MACHINABLE",
          irregular: "IRREGULAR",
          non_machinable: "NON_MACHINABLE"
        }.freeze

        RATE_INDICATORS = {
          three_digit: "3D",
          three_digit_dimensional_rectangular: "3N",
          three_digit_dimensional_nonrectangular: "3R",
          five_digit: "5D",
          basic: "BA",
          mixed_ndc: "BB",
          ndc: "BM",
          cubic_pricing_tier_1: "C1",
          cubic_pricing_tier_2: "C2",
          cubic_pricing_tier_3: "C3",
          cubic_pricing_tier_4: "C4",
          cubic_pricing_tier_5: "C5",
          cubic_parcel: "CP",
          usps_connect_local_mail: "CM",
          ndc_2: "DC",
          scf: "DE",
          five_digit_2: "DF",
          dimensional_nonrectangular: "DN",
          dimensional_rectangular: "DR",
          priority_mail_express_flat_rate_envelope_post_office_to_addressee: "E4",
          priority_mail_express_legal_flat_rate_envelope: "E6",
          priority_mail_express_legal_flat_rate_envelope_sunday_holiday: "E7",
          legal_flat_rate_envelope: "FA",
          medium_flat_rate_box_large_flat_rate_bag: "FB",
          flat_rate_envelope: "FE",
          padded_flat_rate_envelope: "FP",
          small_flat_rate_box: "FS",
          usps_connect_same_day_single_piece: "L1",
          usps_connect_same_day_small_flat_rate_bag: "L2",
          usps_connect_same_day_large_flat_rate_bag: "L3",
          usps_connect_same_day_flat_rate_box: "L4",
          usps_connect_same_day_oversized: "L5",
          usps_connect_local_single_piece: "LC",
          flat_rate_box: "LF",
          large_flat_rate_bag: "LL",
          usps_connect_local_oversized: "LO",
          small_flat_rate_bag: "LS",
          non_presorted: "NP",
          full_tray_box: "O1",
          half_tray_box: "O2",
          emm_tray_box: "O3",
          flat_tub_tray_box: "O4",
          surface_transported_pallet: "O5",
          full_pallet_box: "O6",
          half_pallet_box: "O7",
          oversized: "OS",
          cubic_soft_pack_tier_1: "P5",
          cubic_soft_pack_tier_2: "P6",
          cubic_soft_pack_tier_3: "P7",
          cubic_soft_pack_tier_4: "P8",
          cubic_soft_pack_tier_5: "P9",
          cubic_soft_pack_tier_6: "Q6",
          cubic_soft_pack_tier_7: "Q7",
          cubic_soft_pack_tier_8: "Q8",
          cubic_soft_pack_tier_9: "Q9",
          cubic_soft_pack_tier_10: "Q0",
          priority_mail_express_single_piece: "PA",
          large_flat_rate_box: "PL",
          large_flat_rate_box_apo_fpo_dpo: "PM",
          presorted: "PR",
          usps_connect_next_day_single_piece: "R1",
          usps_connect_next_day_dimensional_nonrectangular: "R2",
          usps_connect_next_day_dimensional_rectangular: "R3",
          usps_connect_next_day_oversized: "R4",
          small_flat_rate_bag_2: "SB",
          scf_dimensional_nonrectangular: "SN",
          single_piece: "SP",
          scf_dimensional_rectangular: "SR"
        }.freeze

        PRICE_TYPES = {
          retail: "RETAIL",
          commercial: "COMMERCIAL",
          contract: "CONTRACT"
        }.freeze

        # @return [String]
        attr_reader :processing_category

        # @return [String]
        attr_reader :rate_indicator

        # @return [String]
        attr_reader :price_type

        # @param processing_category [Symbol] one of {PROCESSING_CATEGORIES}
        # @param rate_indicator [Symbol] one of {RATE_INDICATORS}
        # @param price_type [Symbol] one of {PRICE_TYPES}
        # @param kwargs [Hash]
        # @option [String] :package_id the ID for the package  that belongs to these options
        # @option [Array<ItemOptions>] :item_options the options for items in this package
        # @option [Class] :item_options_class the class to use for item options when none are provided
        def initialize(
          processing_category: :machinable,
          rate_indicator: :single_piece,
          price_type: :retail,
          **kwargs
        )
          @processing_category = PROCESSING_CATEGORIES.fetch(processing_category)
          @rate_indicator = RATE_INDICATORS.fetch(rate_indicator)
          @price_type = PRICE_TYPES.fetch(price_type)
          super(**kwargs)
        end
      end
    end
  end
end
