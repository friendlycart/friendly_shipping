# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class RatesPackageOptions < FriendlyShipping::PackageOptions
        def initialize(**kwargs)
          super(**kwargs.reverse_merge(item_options_class: RatesItemOptions))
        end
      end
    end
  end
end
