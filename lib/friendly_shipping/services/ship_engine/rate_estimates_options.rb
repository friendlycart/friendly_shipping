# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      # Options for the rate estimates API call.
      class RateEstimatesOptions < ShipmentOptions
        # @return [Array<Carrier>] the carriers for these rate estimates
        attr_reader :carriers

        # @return [#strftime]
        attr_reader :ship_date

        # @param carriers [Array<Carrier] the carriers for these rate estimates
        # @param ship_date [#strftime] the date we want to ship on
        # @param kwargs [Hash]
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this shipment
        # @option kwargs [Class] :package_options_class the class to use for package options when none are provided
        def initialize(
          carriers:,
          ship_date: Date.today,
          **kwargs
        )
          @carriers = carriers
          @ship_date = ship_date
          super(**kwargs)
        end

        # @return [Array<String>] the carrier IDs for these rate estimates
        def carrier_ids
          carriers.map(&:id)
        end
      end
    end
  end
end
