# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      class StructureOptions < FriendlyShipping::StructureOptions
        def initialize(**kwargs)
          super(**kwargs.reverse_merge(package_options_class: PackageOptions))
        end
      end
    end
  end
end
