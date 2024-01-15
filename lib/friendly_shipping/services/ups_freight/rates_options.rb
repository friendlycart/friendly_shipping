# frozen_string_literal: true

require 'friendly_shipping/services/ups_freight/rates_package_options'
require 'friendly_shipping/services/ups_freight/generate_commodity_information'

module FriendlyShipping
  module Services
    class UpsFreight
      # Options for generating UPS Freight rates for a shipment
      #
      # @attribute [Physical::Location] billing_address The billing address
      # @attribute [String] shipper_number The shipper number associated with the shipper
      # @attribute [String] customer_context A reference to match this request with an order or shipment
      # @attribute [FriendlyShipping::ShippingMethod] shipping_method The shipping method to use
      # @attribute [Callable] commodity_information_generator A callable that takes a shipment
      #     and an options object to create an Array of commodity fields as per the UPS docs.
      # @attribute [Symbol] billing One of the keys in the `BILLING_CODES` constant. How the shipment
      #     would be billed.
      # @attribute [Date] pickup_date Date of the Pickup
      # @attribute [String] pickup_comments Additional pickup instructions
      # @attribute [RatesPackageOptions] package_options Options for each of the packages/pallets in this shipment
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
                    :shipping_method,
                    :pickup_request_options,
                    :commodity_information_generator,
                    :security_tokens_generator

        def initialize(
          shipper_number:,
          billing_address:,
          shipping_method:,
          billing: :prepaid,
          customer_context: nil,
          pickup_request_options: nil,
          commodity_information_generator: GenerateCommodityInformation,
          security_tokens_generator: nil,
          **kwargs
        )
          @shipper_number = shipper_number
          @billing_address = billing_address
          @shipping_method = shipping_method
          @billing_code = BILLING_CODES.fetch(billing)
          @customer_context = customer_context
          @pickup_request_options = pickup_request_options
          @commodity_information_generator = commodity_information_generator
          @security_tokens_generator = security_tokens_generator
          super(**kwargs.reverse_merge(package_options_class: RatesPackageOptions))
        end
      end
    end
  end
end
