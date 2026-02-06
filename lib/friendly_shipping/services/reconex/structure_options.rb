# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Options for each structure (pallet) in a Reconex quote request.
      class StructureOptions < FriendlyShipping::StructureOptions
        def initialize(**kwargs)
          super(**kwargs.reverse_merge(package_options_class: PackageOptions))
        end
      end
    end
  end
end
