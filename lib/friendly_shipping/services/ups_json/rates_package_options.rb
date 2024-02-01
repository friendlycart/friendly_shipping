# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class RatesPackageOptions < FriendlyShipping::PackageOptions
        attr_reader :transmit_dimensions

        def initialize(transmit_dimensions: true,
                       **kwargs)
          @transmit_dimensions = transmit_dimensions
          super(**kwargs.reverse_merge(item_options_class: RatesItemOptions))
        end
      end
    end
  end
end
