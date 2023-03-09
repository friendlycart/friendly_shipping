# frozen_string_literal: true

require 'friendly_shipping/services/usps_international/rate_estimate_package_options'

module FriendlyShipping
  module Services
    # Option container for rating a shipment via USPS
    #
    # Context: The shipment object we're trying to get results for
    # USPS returns rates on a package-by-package basis, so the options for obtaining rates are
    # set on the [FriendlyShipping/RateEstimateObject] hash. The possible options are:

    # @param [Physical::ShippingMethod] shipping_method The shipping method ("service" in USPS parlance) we want
    #   to get rates for.
    # @param [Boolean] commercial_pricing Whether we prefer commercial pricing results or retail results
    # @param [Boolean] hold_for_pickup Whether we want a rate with Hold For Pickup Service
    class UspsInternational
      class RateEstimateOptions < FriendlyShipping::ShipmentOptions
        def initialize(
          package_options_class: FriendlyShipping::Services::UspsInternational::RateEstimatePackageOptions,
          **kwargs
        )
          super(**kwargs.merge(package_options_class: package_options_class))
        end
      end
    end
  end
end
