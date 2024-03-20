# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      class StructureOptions < FriendlyShipping::StructureOptions
        def initialize(**kwargs)
          super(**kwargs.reverse_merge(package_options_class: RatesPackageOptions))
        end
      end
    end
  end
end
