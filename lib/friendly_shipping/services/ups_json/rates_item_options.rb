# frozen_string_literal: true

require 'friendly_shipping/item_options'

module FriendlyShipping
  module Services
    class UpsJson
      # Represents item options for determining rates.
      # @option commodity_code [String] This item's HS or NMFC code for international shipments.
      # @option country_of_origin [String] This item's country of origin for international shipments.
      class RatesItemOptions < FriendlyShipping::ItemOptions
        attr_reader :commodity_code, :country_of_origin

        def initialize(commodity_code: nil, country_of_origin: nil, **kwargs)
          @commodity_code = commodity_code
          @country_of_origin = country_of_origin
          super(**kwargs)
        end
      end
    end
  end
end
