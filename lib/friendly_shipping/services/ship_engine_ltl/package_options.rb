# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngineLTL
      # Package options for rate quotes.
      class PackageOptions < FriendlyShipping::PackageOptions
        # @return [String]
        attr_reader :packaging_code

        # @return [String]
        attr_reader :freight_class

        # @return [String]
        attr_reader :nmfc_code

        # @return [Boolean]
        attr_reader :stackable

        # @return [Boolean]
        attr_reader :hazardous_materials

        # @param packaging_code [String]
        # @param freight_class [String]
        # @param nmfc_code [String]
        # @param stackable [Boolean]
        # @param hazardous_materials [Boolean]
        # @param kwargs [Hash]
        # @option kwargs [String] :package_id the ID for the package  that belongs to these options
        # @option kwargs [Array<ItemOptions>] :item_options the options for items in this package
        # @option kwargs [Class] :item_options_class the class to use for item options when none are provided
        def initialize(
          packaging_code: nil,
          freight_class: nil,
          nmfc_code: nil,
          stackable: true,
          hazardous_materials: false,
          **kwargs
        )
          @packaging_code = packaging_code
          @freight_class = freight_class
          @nmfc_code = nmfc_code
          @stackable = stackable
          @hazardous_materials = hazardous_materials
          super(**kwargs.reverse_merge(item_options_class: ItemOptions))
        end
      end
    end
  end
end
