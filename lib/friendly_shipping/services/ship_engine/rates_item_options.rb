# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      # Options for each item passed in the rates API call.
      class RatesItemOptions < FriendlyShipping::ItemOptions
        # @return [String] the HS or NMFC code for international shipments
        attr_reader :commodity_code

        # @return [String] the country of origin for international shipments
        attr_reader :country_of_origin

        # @param commodity_code [String] the HS or NMFC code for international shipments
        # @param country_of_origin [String] the country of origin for international shipments
        # @param kwargs [Hash]
        # @option kwargs [String] :item_id the ID for the item that belongs to these options
        def initialize(commodity_code: nil, country_of_origin: nil, **kwargs)
          @commodity_code = commodity_code
          @country_of_origin = country_of_origin
          super(**kwargs)
        end
      end
    end
  end
end
