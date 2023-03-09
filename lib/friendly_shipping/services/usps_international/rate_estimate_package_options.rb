# frozen_string_literal: true

require 'friendly_shipping/services/ups/rate_estimate_package_options'

module FriendlyShipping
  module Services
    # Options for one package when rating
    #
    # @param [Symbol] box_name The type of box we want to get rates for. Has to be one of the keys
    #  of FriendlyShipping::Services::Usps::CONTAINERS.
    # @param [Symbol] return_dimensional_weight Boolean indicating whether the response should include dimensional weight.
    # @param [Symbol] return_fees Boolean indicating whether the response should include fees.
    class UspsInternational
      class RateEstimatePackageOptions < FriendlyShipping::PackageOptions
        attr_reader :box_name,
                    :commercial_pricing,
                    :commercial_plus_pricing,
                    :mail_type,
                    :rectangular,
                    :shipping_method,
                    :transmit_dimensions

        def initialize(**kwargs)
          box_name = value_or_default(:box_name, :variable, kwargs)
          @box_name = CONTAINERS.key?(box_name) ? box_name : :variable
          @commercial_pricing = value_or_default(:commercial_pricing, false, kwargs) ? 'Y' : 'N'
          @commercial_plus_pricing = value_or_default(:commercial_plus_pricing, false, kwargs) ? 'Y' : 'N'
          @mail_type = kwargs.delete(:mail_type)
          @rectangular = value_or_default(:rectangular, true, kwargs)
          @shipping_method = kwargs.delete(:shipping_method)
          @transmit_dimensions = value_or_default(:transmit_dimensions, true, kwargs)
          super(**kwargs)
        end

        def container_code
          CONTAINERS.fetch(box_name)
        end

        def mail_type_code
          MAIL_TYPES[mail_type] || "All"
        end
      end
    end
  end
end
