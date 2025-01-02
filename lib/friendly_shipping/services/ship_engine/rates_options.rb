# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      # Options for the rates API call.
      class RatesOptions < FriendlyShipping::ShipmentOptions
        # @return [Array<Carrier>] the carriers from which to get rates
        attr_reader :carriers

        # @return [String] the service code for which to get rates
        attr_reader :service_code

        # @return [#strftime]
        attr_reader :ship_date

        # @return [String]
        attr_reader :comparison_rate_type

        # @param carriers [Array<Carrier>] the carriers for these rates
        # @param service_code [String] the service code to use when getting rates
        # @param ship_date [#strftime] the date we want to ship on
        # @param comparison_rate_type [String] set to "retail" for retail rates (UPS/USPS only)
        # @param kwargs [Hash]
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this shipment
        # @option kwargs [Class] :package_options_class the class to use for package options when none are provided
        def initialize(
          carriers:,
          service_code:,
          ship_date: Date.today,
          comparison_rate_type: nil,
          **kwargs
        )
          @carriers = carriers
          @service_code = service_code
          @ship_date = ship_date
          @comparison_rate_type = comparison_rate_type
          validate_comparison_rate_type!
          super(**kwargs.reverse_merge(package_options_class: RatesPackageOptions))
        end

        # @return [Array<String>] the carrier IDs for these rates
        def carrier_ids
          carriers.map(&:id)
        end

        private

        # @raise [ArgumentError] invalid comparison rate type
        # @return [nil]
        def validate_comparison_rate_type!
          return if comparison_rate_type.nil? || comparison_rate_type == "retail"

          raise ArgumentError, "Invalid comparison rate type: #{comparison_rate_type}"
        end
      end
    end
  end
end
