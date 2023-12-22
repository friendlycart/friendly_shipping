# frozen_string_literal: true

require 'friendly_shipping/services/tforce_freight/rates_item_options'

module FriendlyShipping
  module Services
    class TForceFreight
      # Options for packages/pallets within a TForce Freight shipment
      class RatesPackageOptions < FriendlyShipping::PackageOptions
        def initialize(**kwargs)
          super(**kwargs.reverse_merge(item_options_class: RatesItemOptions))
        end
      end
    end
  end
end
