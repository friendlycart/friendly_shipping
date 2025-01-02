# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Serializes items for R+L API requests.
      class ItemOptions < FriendlyShipping::ItemOptions
        # @return [String] the freight class
        attr_reader :freight_class

        # @return [String] the NMFC primary code
        attr_reader :nmfc_primary_code

        # @return [String] the NMFC sub code
        attr_reader :nmfc_sub_code

        # @param freight_class [String] the freight class
        # @param nmfc_primary_code [String] the NMFC primary code
        # @param nmfc_sub_code [String] the NMFC sub code
        # @param kwargs [Hash]
        # @option kwargs [String] :item_id the ID for the item that belongs to these options
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
