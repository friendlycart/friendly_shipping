# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      class ChoosePackageRate
        class CannotDetermineRate < StandardError; end
        # Some shipping rates use 'Flat Rate Boxes', indicating that
        # they are available for ALL flat rate boxes.
        FLAT_RATE_BOX = /Flat Rate Box/i.freeze

        # Select the corresponding rate for a package from all the rates USPS returns to us
        #
        # @param [FriendlyShipping::ShippingMethod] shipping_method The shipping method we want to filter by
        # @param [Physical::Package] package The package we want to match with a rate
        # @param [Array<FriendlyShipping::Rate>] The rates we select from
        #
        # @return [FriendlyShipping::Rate] The rate that most closely matches our package
        def self.call(shipping_method, package, rates)
          # Remove all rates with the wrong shipping method
          rates_with_this_shipping_method = rates.select { |r| r.shipping_method == shipping_method }

          # Remove all the rates with the wrong box type
          rates_with_this_package_type = rates_with_this_shipping_method.select do |r|
            r.data[:box_name] == package.properties[:box_name] ||
              r.data[:box_name] == :flat_rate_boxes && package.properties[:box_name]&.match?(FLAT_RATE_BOX)
          end

          # Filter by our package's `hold_for_pickup` option
          rates_with_this_hold_for_pickup_option = rates_with_this_package_type.select do |r|
            r.data[:hold_for_pickup] == !!package.properties[:hold_for_pickup]
          end

          # At this point we should be left with a single rate. If we are not, raise an error,
          # as that means we're missing some code.
          if rates_with_this_hold_for_pickup_option.length > 1
            raise CannotDetermineRate
          end

          # As we only have one rate left, return that without the array.
          rates_with_this_hold_for_pickup_option.first
        end
      end
    end
  end
end
