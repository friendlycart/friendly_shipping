# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Options for structures when generating UPS Freight labels. Uses {LabelPackageOptions} for packages by default.
      class LabelStructureOptions < RatesStructureOptions
        # @param kwargs [Hash] see {RatesStructureOptions#initialize}
        def initialize(**kwargs)
          super(**kwargs.reverse_merge(package_options_class: LabelPackageOptions))
        end
      end
    end
  end
end
