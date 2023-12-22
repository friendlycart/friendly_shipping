# frozen_string_literal: true

require 'friendly_shipping/item_options'

module FriendlyShipping
  module Services
    class RL
      class ItemOptions < FriendlyShipping::ItemOptions
        attr_reader :freight_class,
                    :nmfc_primary_code,
                    :nmfc_sub_code

        # @param [String] freight_class
        # @param [String] nmfc_primary_code
        # @param [String] nmfc_sub_code
        # @param [Array<Object>] **kwargs
        def initialize(
          freight_class: nil,
          nmfc_primary_code: nil,
          nmfc_sub_code: nil,
          **kwargs
        )
          @freight_class = freight_class
          @nmfc_primary_code = nmfc_primary_code
          @nmfc_sub_code = nmfc_sub_code
          super(**kwargs)
        end
      end
    end
  end
end
