# frozen_string_literal: true

module FriendlyShipping
  module Services
    class USPSShip
      class RateEstimateOptions < FriendlyShipping::ShipmentOptions
        DESTINATION_ENTRY_FACILITY_TYPES = {
          none: "NONE",
          destination_network_distribution_center: "DESTINATION_NETWORK_DISTRIBUTION_CENTER",
          destination_sectional_center_facility: "DESTINATION_SECTIONAL_CENTER_FACILITY",
          destination_delivery_unit: "DESTINATION_DELIVERY_UNIT",
          destination_service_hub: "DESTINATION_SERVICE_HUB"
        }.freeze

        # @return [ShippingMethod]
        attr_reader :shipping_method

        # @return [String]
        attr_reader :destination_entry_facility_type

        # @return [#strftime]
        attr_reader :mailing_date

        # @param shipping_method [ShippingMethod] the shipping method for which we want a rate
        # @param destination_entry_facility_type [Symbol] one of {DESTINATION_ENTRY_FACILITY_TYPES}
        # @param mailing_date [#strftime] the date on which we want to ship
        # @param package_options_class [Class] the class to use for package options
        # @param kwargs [Hash]
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this shipment
        def initialize(
          shipping_method:,
          destination_entry_facility_type: :none,
          mailing_date: Date.today,
          package_options_class: FriendlyShipping::Services::USPSShip::RateEstimatePackageOptions,
          **kwargs
        )
          @shipping_method = shipping_method
          @destination_entry_facility_type = DESTINATION_ENTRY_FACILITY_TYPES.fetch(destination_entry_facility_type)
          @mailing_date = mailing_date
          super(**kwargs.reverse_merge(package_options_class: package_options_class))
        end
      end
    end
  end
end
