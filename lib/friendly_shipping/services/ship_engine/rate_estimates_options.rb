# frozen_string_literal: true

require 'friendly_shipping/shipment_options'

module FriendlyShipping
  module Services
    class ShipEngine
      # options for the rate estimates call
      #
      # @attribute carriers [Array<FriendlyShipping::Carrier] a list of the carriers we want to get IDs from.
      # @attribute ship_date [#strftime] the date we want to ship on.
      class RateEstimatesOptions < ShipmentOptions
        attr_reader :carriers,
                    :ship_date

        def initialize(
          carriers:,
          ship_date: Date.today,
          **kwargs
        )
          @carriers = carriers
          @ship_date = ship_date
          super(**kwargs)
        end

        def carrier_ids
          carriers.map(&:id)
        end
      end
    end
  end
end
