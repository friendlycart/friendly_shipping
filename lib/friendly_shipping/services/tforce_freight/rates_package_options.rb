# frozen_string_literal: true

require 'friendly_shipping/services/tforce_freight/rates_item_options'

module FriendlyShipping
  module Services
    class TForceFreight
      # Options for packages/pallets in a shipment.
      class RatesPackageOptions < FriendlyShipping::PackageOptions
        # Maps friendly names to handling unit types.
        HANDLING_UNIT_TYPES = {
          pallet: { code: "PLT", description: "Pallet", handling_unit_tag: 'One' },
          skid: { code: "SKD", description: "Skid", handling_unit_tag: 'One' },
          carboy: { code: "CBY", description: "Carboy", handling_unit_tag: 'One' },
          totes: { code: "TOT", description: "Totes", handling_unit_tag: 'One' },
          other: { code: "OTH", description: "Other", handling_unit_tag: 'Two' },
          loose: { code: "LOO", description: "Loose", handling_unit_tag: 'Two' }
        }.freeze

        # @return [String] the handling unit description
        attr_reader :handling_unit_description

        # @return [String] the handling unit tag
        attr_reader :handling_unit_tag

        # @return [String] the handling unit code
        attr_reader :handling_unit_code

        # @param handling_unit [Symbol] the handling unit for this package/pallet
        # @param kwargs [Hash]
        # @option kwargs [String] :package_id the ID for the package  that belongs to these options
        # @option kwargs [Array<ItemOptions>] :item_options the options for items in this package
        # @option kwargs [Class] :item_options_class the class to use for item options when none are provided
        def initialize(
          handling_unit: :pallet,
          **kwargs
        )
          @handling_unit_code = HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:code)
          @handling_unit_description = HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:description)
          @handling_unit_tag = "handlingUnit#{HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:handling_unit_tag)}"
          super(**kwargs.reverse_merge(item_options_class: ItemOptions))
        end
      end
    end
  end
end
