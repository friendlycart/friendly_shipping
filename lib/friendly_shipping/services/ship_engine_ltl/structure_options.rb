# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngineLTL
      class StructureOptions < FriendlyShipping::StructureOptions
        # @param kwargs [Hash]
        # @option kwargs [String] :structure_id
        # @option kwargs [Array<PackageOptions>] :package_options
        # @option kwargs [Class] :package_options_class
        def initialize(**kwargs)
          super(**kwargs.reverse_merge(package_options_class: PackageOptions))
        end
      end
    end
  end
end
