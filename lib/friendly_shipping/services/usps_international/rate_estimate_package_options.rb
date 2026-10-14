# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UspsInternational
      # Options for one package when rating
      class RateEstimatePackageOptions < FriendlyShipping::PackageOptions
        # @return [Symbol] the type of box we want to get rates for
        attr_reader :box_name

        # @return [String] 'Y' if the response should include commercial pricing rates, 'N' otherwise
        attr_reader :commercial_pricing

        # @return [String] 'Y' if the response should include commercial plus pricing rates, 'N' otherwise
        attr_reader :commercial_plus_pricing

        # @return [String] the USPS code for the type of container of the package
        attr_reader :container

        # @return [String] the USPS code for the type of mail to estimate rates for
        attr_reader :mail_type

        # @return [Boolean] whether the package is rectangular
        attr_reader :rectangular

        # @return [ShippingMethod] the requested shipping method
        attr_reader :shipping_method

        # @return [Boolean] whether the request should include the package dimensions
        attr_reader :transmit_dimensions

        # @param kwargs [Hash] options passed on to {FriendlyShipping::PackageOptions}
        # @option kwargs [Symbol] :box_name the type of box we want to get rates for
        # @option kwargs [Boolean] :commercial_pricing whether the response should include commercial pricing rates
        # @option kwargs [Boolean] :commercial_plus_pricing whether the response should include commercial plus pricing rates
        # @option kwargs [Symbol] :container the type of container of the package, a key of {CONTAINERS}
        # @option kwargs [Symbol] :mail_type the type of mail to estimate rates for, a key of {MAIL_TYPES}
        # @option kwargs [Boolean] :rectangular whether the package is rectangular (always false for rolls)
        # @option kwargs [ShippingMethod] :shipping_method the requested shipping method
        # @option kwargs [Boolean] :transmit_dimensions whether the request should include the package dimensions
        def initialize(**kwargs)
          container_code = value_or_default(:container, :variable, kwargs) || :variable
          mail_type_code = value_or_default(:mail_type, :all, kwargs) || :all

          @box_name = value_or_default(:box_name, :variable, kwargs)
          @commercial_pricing = value_or_default(:commercial_pricing, false, kwargs) ? 'Y' : 'N'
          @commercial_plus_pricing = value_or_default(:commercial_plus_pricing, false, kwargs) ? 'Y' : 'N'
          @container = CONTAINERS.fetch(container_code)
          @mail_type = MAIL_TYPES.fetch(mail_type_code)
          @rectangular = @container.eql?("ROLL") ? false : value_or_default(:rectangular, true, kwargs)
          @shipping_method = kwargs.delete(:shipping_method)
          @transmit_dimensions = value_or_default(:transmit_dimensions, true, kwargs)
          super(**kwargs)
        end
      end
    end
  end
end
