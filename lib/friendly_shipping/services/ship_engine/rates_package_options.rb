# frozen_string_literal: true

require 'friendly_shipping/services/ups_freight/rates_item_options'

module FriendlyShipping
  module Services
    class ShipEngine
      # Options for each package passed in the rates API call.
      class RatesPackageOptions < FriendlyShipping::PackageOptions
        # @param kwargs [Hash]
        # @option kwargs [String] :package_id the ID for the package  that belongs to these options
        # @option kwargs [Array<ItemOptions>] :item_options the options for items in this package
        # @option kwargs [Class] :item_options_class the class to use for item options when none are provided
        def initialize(**kwargs)
          super(**kwargs.reverse_merge(item_options_class: RatesItemOptions))
        end
      end
    end
  end
end
