# frozen_string_literal: true

require 'friendly_shipping/services/ups/rate_estimate_package_options'

module FriendlyShipping
  module Services
    # Options for one package when rating
    #
    # @param [Symbol] box_name The type of box we want to get rates for. Has to be one of the keys
    #  of FriendlyShipping::Services::Usps::CONTAINERS.
    class Usps
      class RateEstimatePackageOptions < FriendlyShipping::PackageOptions
        attr_reader :box_name,
                    :commercial_pricing,
                    :first_class_mail_type,
                    :hold_for_pickup,
                    :shipping_method

        def initialize(
          box_name: :variable,
          commercial_pricing: false,
          first_class_mail_type: nil,
          hold_for_pickup: false,
          shipping_method: nil,
          **kwargs
        )
          @box_name = CONTAINERS.key?(box_name) ? box_name : :variable
          @commercial_pricing = commercial_pricing
          @first_class_mail_type = first_class_mail_type
          @hold_for_pickup = hold_for_pickup
          @shipping_method = shipping_method
          super kwargs
        end

        def container_code
          CONTAINERS.fetch(box_name)
        end

        def first_class_mail_type_code
          FIRST_CLASS_MAIL_TYPES[first_class_mail_type]
        end

        def service_code
          return 'ALL' unless shipping_method

          if commercial_pricing
            "#{shipping_method.service_code} COMMERCIAL"
          else
            shipping_method.service_code
          end
        end
      end
    end
  end
end
