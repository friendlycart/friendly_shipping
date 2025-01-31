# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
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
          super(**kwargs.reverse_merge(package_options_class: PackageOptions))
        end

        # @param [#id] structure
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
        # @deprecated Use {#structures_serializer} instead.
        attr_reader :package_options

        # @return [Class]
        # @deprecated Use {#structures_serializer_class} instead.
        attr_reader :package_options_class
      end
    end
  end
end
