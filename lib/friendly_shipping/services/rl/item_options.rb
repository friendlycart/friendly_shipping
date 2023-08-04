# frozen_string_literal: true

require 'friendly_shipping/item_options'

module FriendlyShipping
  module Services
    class RL
      class ItemOptions < FriendlyShipping::ItemOptions
        attr_reader :freight_class

        # @param [String] freight_class
        # @param [Array<Object>] **kwargs
        def initialize(
          freight_class: nil,
          **kwargs
        )
          @freight_class = freight_class
          super(**kwargs)
        end
      end
    end
  end
end
