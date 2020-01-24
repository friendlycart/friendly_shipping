# frozen_string_literal: true

require 'friendly_shipping/services/ups/label_item_options'

module FriendlyShipping
  module Services
    class Ups
      # Package properties relevant for quoting a UPS package
      #
      # @option transmit_dimensions [Boolean] Whether to transmit the dimensions of this package, or quote only based on weight.
      class RateEstimatePackageOptions < FriendlyShipping::PackageOptions
        attr_reader :transmit_dimensions

        def initialize(
          transmit_dimensions: true,
          **kwargs
        )
          @transmit_dimensions = transmit_dimensions
          super kwargs
        end
      end
    end
  end
end
