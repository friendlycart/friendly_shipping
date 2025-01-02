# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Serializes packages for R+L API requests.
      class PackageOptions < FriendlyShipping::PackageOptions
        # @return [String]
        attr_reader :freight_class

        # @return [String]
        attr_reader :nmfc_primary_code

        # @return [String]
        attr_reader :nmfc_sub_code

        # @param freight_class [String] the freight class
        # @param nmfc_primary_code [String] the NMFC primary code
        # @param nmfc_sub_code [String] the NMFC sub code
        # @param kwargs [Hash]
        # @option kwargs [String] :package_id the ID for the package that belongs to these options
        # @option kwargs [Array<ItemOptions>] :item_options the options for items in this package
        # @option kwargs [Class] :item_options_class the class to use for item options when none are provided
        def initialize(
          freight_class: nil,
          nmfc_primary_code: nil,
          nmfc_sub_code: nil,
          **kwargs
        )
          @freight_class = freight_class
          @nmfc_primary_code = nmfc_primary_code
          @nmfc_sub_code = nmfc_sub_code
          super(**kwargs.reverse_merge(item_options_class: ItemOptions))
        end
      end
    end
  end
end
