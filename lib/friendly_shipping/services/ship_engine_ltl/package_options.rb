# frozen_string_literal: true

require 'friendly_shipping/services/ups/label_item_options'

module FriendlyShipping
  module Services
    class ShipEngineLTL
      class PackageOptions < FriendlyShipping::PackageOptions
        def initialize(**kwargs)
          super(**kwargs.reverse_merge(item_options_class: ItemOptions))
        end
      end
    end
  end
end
