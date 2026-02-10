# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Options for each structure (pallet) in a Reconex quote request.
      class StructureOptions < FriendlyShipping::StructureOptions
        # @param kwargs [Hash]
        # @option kwargs [Object] :structure_id unique identifier for this structure
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this structure
        # @option kwargs [Class] :package_options_class the class for package options (defaults to {PackageOptions})
        def initialize(**kwargs)
          super(**kwargs.reverse_merge(package_options_class: PackageOptions))
        end
      end
    end
  end
end
