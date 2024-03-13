# frozen_string_literal: true

require 'friendly_shipping/shipment_options'

module FriendlyShipping
  module Services
    class ShipEngine
      # Options for generating rate estimates for a shipment.
      class RateEstimatesOptions < ShipmentOptions
        # @return [Array<Carrier>]
        attr_reader :carriers

        # @return [#strftime]
        attr_reader :ship_date

        # @param carriers [Array<Carrier>] the carriers for which we want to get rate estimates
        # @param ship_date [#strftime] the date we want to ship on
        # @param kwargs [Hash]
        # @option kwargs [Enumerable<PackageOptions>] :package_options the options for packages in this shipment
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

        # @return [Array<String>]
        def carrier_ids
          carriers.map(&:id)
        end
      end
    end
  end
end
