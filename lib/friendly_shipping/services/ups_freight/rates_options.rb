# frozen_string_literal: true

require 'friendly_shipping/services/ups_freight/shipment_options'
require 'friendly_shipping/services/ups_freight/rates_package_options'
require 'friendly_shipping/services/ups_freight/generate_commodity_information'

module FriendlyShipping
  module Services
    class UpsFreight
      # Options for generating UPS Freight rates for a shipment
      class RatesOptions < ShipmentOptions
        BILLING_CODES = {
          prepaid: '10',
          third_party: '30',
          freight_collect: '40'
        }.freeze

        # @return [String]
        attr_reader :shipper_number

        # @return [Physical::Location]
        attr_reader :billing_address

        # @return [Symbol]
        attr_reader :billing_code

        # @return [String]
        attr_reader :customer_context

        # @return [FriendlyShipping::ShippingMethod]
        attr_reader :shipping_method

        # @return [PickupRequestOptions]
        attr_reader :pickup_request_options

        # @return [Callable]
        attr_reader :commodity_information_generator

        # @param shipper_number [String] the shipper number associated with the shipper
        # @param billing_address [Physical::Location] the billing address
        # @param shipping_method [FriendlyShipping::ShippingMethod] the shipping method to use
        # @param billing [Symbol] how the shipment is billed (see {BILLING_CODES})
        # @param customer_context [String] a reference to match this request with an order or shipment
        # @param pickup_request_options [PickupRequestOptions] options for the pickup request
        # @param commodity_information_generator [Callable] a callable that takes a shipment
        #     and an options object to create an Array of commodity fields as per the UPS docs
        def initialize(
          shipper_number:,
          billing_address:,
          shipping_method:,
          billing: :prepaid,
          customer_context: nil,
          pickup_request_options: nil,
          commodity_information_generator: GenerateCommodityInformation,
          **kwargs
        )
          @shipper_number = shipper_number
          @billing_address = billing_address
          @shipping_method = shipping_method
          @billing_code = BILLING_CODES.fetch(billing)
          @customer_context = customer_context
          @pickup_request_options = pickup_request_options
          @commodity_information_generator = commodity_information_generator
          super(**kwargs.reverse_merge(package_options_class: RatesPackageOptions))
        end
      end
    end
  end
end
