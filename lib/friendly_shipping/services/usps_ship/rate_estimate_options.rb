# frozen_string_literal: true

module FriendlyShipping
  module Services
    class USPSShip
      class RateEstimateOptions < FriendlyShipping::ShipmentOptions
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

        DESTINATION_ENTRY_FACILITY_TYPES = {
          none: "NONE",
          destination_network_distribution_center: "DESTINATION_NETWORK_DISTRIBUTION_CENTER",
          destination_sectional_center_facility: "DESTINATION_SECTIONAL_CENTER_FACILITY",
          destination_delivery_unit: "DESTINATION_DELIVERY_UNIT",
          destination_service_hub: "DESTINATION_SERVICE_HUB"
        }.freeze

        PRICE_TYPES = {
          retail: "RETAIL",
          commercial: "COMMERCIAL",
          contract: "CONTRACT"
        }.freeze

        # @return [ShippingMethod]
        attr_reader :shipping_method

        # @return [String]
        attr_reader :processing_category

        # @return [String]
        attr_reader :rate_indicator

        # @return [String]
        attr_reader :destination_entry_facility_type

        # @return [String]
        attr_reader :price_type

        # @return [#strftime]
        attr_reader :mailing_date

        # @param shipping_method [ShippingMethod] the shipping method for which we want a rate
        # @param processing_category [Symbol] one of {PROCESSING_CATEGORIES}
        # @param rate_indicator [Symbol] one of {RATE_INDICATORS}
        # @param destination_entry_facility_type [Symbol] one of {DESTINATION_ENTRY_FACILITY_TYPES}
        # @param price_type [Symbol] one of {PRICE_TYPES}
        # @param mailing_date [#strftime] the date on which we want to ship
        # @param kwargs [Hash]
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this shipment
        # @option kwargs [Class] :package_options_class the class to use for package options when none are provided
        def initialize(
          shipping_method:,
          processing_category: :machinable,
          rate_indicator: :dimensional_rectangular,
          destination_entry_facility_type: :none,
          price_type: :retail,
          mailing_date: Date.today,
          **kwargs
        )
          @shipping_method = shipping_method
          @processing_category = PROCESSING_CATEGORIES.fetch(processing_category)
          @rate_indicator = RATE_INDICATORS.fetch(rate_indicator)
          @destination_entry_facility_type = DESTINATION_ENTRY_FACILITY_TYPES.fetch(destination_entry_facility_type)
          @price_type = PRICE_TYPES.fetch(price_type)
          @mailing_date = mailing_date
          super(**kwargs)
        end
      end
    end
  end
end
