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
    class Usps
      class RateEstimatePackageOptions < FriendlyShipping::PackageOptions
        attr_reader :box_name,
                    :commercial_pricing,
                    :first_class_mail_type,
                    :hold_for_pickup,
                    :shipping_method,
                    :transmit_dimensions,
                    :rectangular,
                    :return_dimensional_weight,
                    :return_fees

        def initialize(**kwargs)
          box_name = value_or_default(:box_name, :variable, kwargs)
          @box_name = CONTAINERS.key?(box_name) ? box_name : :variable
          @commercial_pricing = value_or_default(:commercial_pricing, false, kwargs)
          @first_class_mail_type = kwargs.delete(:first_class_mail_type)
          @hold_for_pickup = value_or_default(:hold_for_pickup, false, kwargs)
          @shipping_method = kwargs.delete(:shipping_method)
          @transmit_dimensions = value_or_default(:transmit_dimensions, true, kwargs)
          @rectangular = value_or_default(:rectangular, true, kwargs)
          @return_dimensional_weight = value_or_default(:return_dimensional_weight, true, kwargs)
          @return_fees = value_or_default(:return_fees, false, kwargs)
          super(**kwargs)
        end

        def container_code
          CONTAINERS.fetch(box_name)
        end

        def first_class_mail_type_code
          FIRST_CLASS_MAIL_TYPES[first_class_mail_type]
        end

        def service_code
          return 'ALL' unless shipping_method

          # Cubic shipping methods don't have HFP or COMMERCIAL modifiers
          return shipping_method.service_code if shipping_method.service_code =~ /CUBIC/

          service_code = [shipping_method.service_code]
          service_code << 'HFP' if hold_for_pickup
          service_code << 'COMMERCIAL' if commercial_pricing
          service_code.join(' ')
        end

        private

        def value_or_default(key, default, kwargs)
          kwargs.key?(key) ? kwargs.delete(key) : default
        end
      end
    end
  end
end
