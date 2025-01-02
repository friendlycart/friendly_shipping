# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Options for structures/pallets within a UPS Freight shipment.
      class RatesStructureOptions < FriendlyShipping::StructureOptions
        # Maps friendly names to handling unit types.
        HANDLING_UNIT_TYPES = {
          pallet: { code: "PLT", description: "Pallet", handling_unit_tag: 'One' },
          skid: { code: "SKD", description: "Skid", handling_unit_tag: 'One' },
          carboy: { code: "CBY", description: "Carboy", handling_unit_tag: 'One' },
          totes: { code: "TOT", description: "Totes", handling_unit_tag: 'One' },
          other: { code: "OTH", description: "Other", handling_unit_tag: 'Two' },
          loose: { code: "LOO", description: "Loose", handling_unit_tag: 'Two' }
        }.freeze

        # @return [String]
        attr_reader :handling_unit_description

        # @return [String]
        attr_reader :handling_unit_tag

        # @return [String]
        attr_reader :handling_unit_code

        # @param handling_unit [Symbol] how this shipment is divided (see {HANDLING_UNIT_TYPES})
        # @param kwargs [Hash]
        # @options kwargs [Object] :structure_id unique identifier for this set of options
        # @options kwargs [Array<PackageOptions>] :package_options the options for packages in this structure
        # @options kwargs [Class] :package_options_class the class to use for package options when none are provided
        def initialize(
          handling_unit: :pallet,
          **kwargs
        )
          @handling_unit_code = HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:code)
          @handling_unit_description = HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:description)
          @handling_unit_tag = "HandlingUnit#{HANDLING_UNIT_TYPES.fetch(handling_unit).fetch(:handling_unit_tag)}"
          super(**kwargs.reverse_merge(package_options_class: RatesPackageOptions))
        end
      end
    end
  end
end
