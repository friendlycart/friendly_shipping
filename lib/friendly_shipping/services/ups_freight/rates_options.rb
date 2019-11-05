# frozen_string_literal: true

require 'friendly_shipping/services/ups_freight/rates_package_options'

module FriendlyShipping
  module Services
    class UpsFreight
      class RatesOptions < FriendlyShipping::ShipmentOptions
        BILLING_CODES = {
          prepaid: '10',
          third_party: '30',
          freight_collect: '40'
        }.freeze

        attr_reader :shipper_number,
                    :billing_address,
                    :billing_code,
                    :customer_context,
                    :shipping_method

        def initialize(
          shipper_number:,
          billing_address:,
          shipping_method:,
          billing: :prepaid,
          customer_context: nil,
          **kwargs
        )
          @shipper_number = shipper_number
          @billing_address = billing_address
          @shipping_method = shipping_method
          @billing_code = BILLING_CODES.fetch(billing)
          @customer_context = customer_context
          super kwargs.merge(package_options_class: RatesPackageOptions)
        end
      end
    end
  end
end
