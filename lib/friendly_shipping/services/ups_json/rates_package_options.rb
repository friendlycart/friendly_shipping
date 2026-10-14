# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Package properties relevant for rating a shipment via UPS.
      # @option transmit_dimensions [Boolean] whether to send the package's dimensions to UPS. Default: true
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
