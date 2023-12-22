# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class LabelStructureOptions < RatesStructureOptions
        def initialize(**kwargs)
          super(**kwargs.reverse_merge(package_options_class: LabelPackageOptions))
        end
      end
    end
  end
end
