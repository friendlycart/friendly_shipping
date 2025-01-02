# frozen_string_literal: true

module FriendlyShipping
  module Services
    # Options for one package when rating
    #
    # @param [Symbol] box_name The type of box we want to get rates for.
    # @param [Boolean] commercial_pricing Indicate whether the response should include commercial pricing rates.
    # @param [Boolean] commercial_plus_pricing Indicate whether the response should include commercial pluse pricing rates.
    # @param [Symbol] container_code Indicate the type of container of the package.
    # @param [Symbol] mail_type Indicate the type of mail to estimate rates.
    # @param [Boolean] rectangular Indicate whether the package is rectangular.
    # @param [FriendlyShipping::ShippingMethod] shipping_method Describe the requested shipping method.
    # @param [Symbol] transmit_dimensions Indicate whether the request should include the package dimensionals.
    class UspsInternational
      class RateEstimatePackageOptions < FriendlyShipping::PackageOptions
        attr_reader :box_name,
                    :commercial_pricing,
                    :commercial_plus_pricing,
                    :container,
                    :mail_type,
                    :rectangular,
                    :shipping_method,
                    :transmit_dimensions

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
