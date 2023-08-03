# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngineLTL
      class ItemOptions < FriendlyShipping::ItemOptions
        attr_reader :packaging_code,
                    :freight_class,
                    :nmfc_code,
                    :stackable,
                    :hazardous_materials

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
