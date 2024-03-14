# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngineLTL
      # Item options for rate quotes.
      class ItemOptions < FriendlyShipping::ItemOptions
        # @return [String] the packaging code
        attr_reader :packaging_code

        # @return [String] the freight class
        attr_reader :freight_class

        # @return [String] the NMFC code
        attr_reader :nmfc_code

        # @return [Boolean] whether the item is stackable
        attr_reader :stackable

        # @return [Boolean] whether the item contains hazardous materials
        attr_reader :hazardous_materials

        # @param packaging_code [String] the packaging code
        # @param freight_class [String] the freight class
        # @param nmfc_code [String] the NMFC code
        # @param stackable [Boolean] whether the item is stackable
        # @param hazardous_materials [Boolean] whether the item contains hazardous materials
        # @param kwargs [Hash]
        # @option kwargs [String] :item_id the ID for the item that belongs to these options
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
          super(**kwargs)
        end
      end
    end
  end
end
