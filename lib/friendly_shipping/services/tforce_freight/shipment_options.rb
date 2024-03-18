# frozen_string_literal: true

require 'friendly_shipping/shipment_options'

module FriendlyShipping
  module Services
    class TForceFreight
      class ShipmentOptions < FriendlyShipping::ShipmentOptions
        # @param structure_options [Array<StructureOptions>]
        # @param structure_options_class [Class]
        # @param kwargs [Hash]
        # @option kwargs [Array<PackageOptions>] :package_options
        # @option kwargs [Class] :package_options_class
        def initialize(
          structure_options: Set.new,
          structure_options_class: StructureOptions,
          **kwargs
        )
          @structure_options = structure_options
          @structure_options_class = structure_options_class
          super(**kwargs.reverse_merge(package_options_class: RatesPackageOptions))
        end

        # @param structure [#id]
        # @return [StructureOptions]
        def options_for_structure(structure)
          structure_options.detect do |structure_option|
            structure_option.structure_id == structure.id
          end || structure_options_class.new(structure_id: nil)
        end

        private

        # @return [Array<StructureOptions>]
        attr_reader :structure_options

        # @return [Class]
        attr_reader :structure_options_class

        # @return [Array<PackageOptions>]
        # @deprecated Use {#structure_options} instead.
        def package_options
          warn "[DEPRECATION] `package_options` is deprecated.  Please use `structure_options` instead."
          @package_options
        end
      end
    end
  end
end
