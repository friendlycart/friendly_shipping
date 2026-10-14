# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UspsInternational
      # Option container for rating a shipment via USPS International
      #
      # USPS returns rates on a package-by-package basis, so the options that influence the
      # rates (such as box name and pricing type) are set on {RateEstimatePackageOptions}.
      class RateEstimateOptions < FriendlyShipping::ShipmentOptions
        # @param package_options_class [Class] the class to use for package options
        # @param kwargs [Hash]
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this shipment
        def initialize(
          package_options_class: FriendlyShipping::Services::UspsInternational::RateEstimatePackageOptions,
          **kwargs
        )
          super(**kwargs.reverse_merge(package_options_class: package_options_class))
        end
      end
    end
  end
end
