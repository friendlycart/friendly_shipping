# frozen_string_literal: true

require 'friendly_shipping/services/ups_freight/rates_item_options'

module FriendlyShipping
  module Services
    class ShipEngine
      # Options for packages within a ShipEngine shipment
      #
      # @attribute [RatesItemOptions] item_options Options for each of the items in the package
      class RatesPackageOptions < FriendlyShipping::PackageOptions
        def initialize(**kwargs)
          super(**kwargs.merge(item_options_class: RatesItemOptions))
        end
      end
    end
  end
end
