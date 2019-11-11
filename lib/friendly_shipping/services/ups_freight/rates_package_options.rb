# frozen_string_literal: true

require 'friendly_shipping/services/ups_freight/rates_item_options'

module FriendlyShipping
  module Services
    class UpsFreight
      # Options for packages/pallets within a UPS Freight shipment
      #
      # @attribute [Symbol] handling _unit How this shipment is divided. Any of the keys in `HANDLING_UNIT_TYPES`
      # @attribute [RatesItemOptions] item_options Options for each of the items on the pallet/in the carboy/etc.
      class RatesPackageOptions < FriendlyShipping::PackageOptions
        HANDLING_UNIT_TYPES = {
          pallet: { code: "PLT", description: "Pallet", handling_unit_tag: 'One' },
          skid: { code: "SKD", description: "Skid", handling_unit_tag: 'One' },
          carboy: { code: "CBY", description: "Carboy", handling_unit_tag: 'One' },
          totes: { code: "TOT", description: "Totes", handling_unit_tag: 'One' },
          other: { code: "OTH", description: "Other", handling_unit_tag: 'Two' },
          loose: { code: "LOO", description: "Loose", handling_unit_tag: 'Two' }
        }.freeze

        attr_reader :handling_unit_description,
                    :handling_unit_tag,
                    :handling_unit_code

        def initialize(
          handling_unit: :pallet,
          **kwargs
        )
          @handling_unit_code = HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:code)
          @handling_unit_description = HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:description)
          @handling_unit_tag = "HandlingUnit#{HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:handling_unit_tag)}"
          super kwargs.merge(item_options_class: RatesItemOptions)
        end
      end
    end
  end
end
