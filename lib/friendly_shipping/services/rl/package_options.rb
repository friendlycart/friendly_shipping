# frozen_string_literal: true

require 'friendly_shipping/package_options'

module FriendlyShipping
  module Services
    class RL
      class PackageOptions < FriendlyShipping::PackageOptions
        # @param [Array<Object>] **kwargs
        def initialize(**kwargs)
          super(**kwargs.reverse_merge(item_options_class: ItemOptions))
        end
      end
    end
  end
end
