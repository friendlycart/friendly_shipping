# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Options for generating UPS Freight rates for a shipment
      class RatesOptions < ShipmentOptions
        # Maps friendly names to billing option codes.
        BILLING_CODES = {
          prepaid: '10',
          third_party: '30',
          freight_collect: '40'
        }.freeze

        # @return [String] the shipper number associated with the shipper
        attr_reader :shipper_number

        # @return [Physical::Location] the billing address
        attr_reader :billing_address

        # @return [String] the billing option code (see {BILLING_CODES})
        attr_reader :billing_code

        # @return [String, nil] a reference to match the request with an order or shipment
        attr_reader :customer_context

        # @return [FriendlyShipping::ShippingMethod] the shipping method to use
        attr_reader :shipping_method

        # @return [PickupRequestOptions, nil] options for the pickup request
        attr_reader :pickup_request_options

        # @return [#call] a callable that generates the commodity information
        attr_reader :commodity_information_generator

        # @param shipper_number [String] the shipper number associated with the shipper
        # @param billing_address [Physical::Location] the billing address
        # @param shipping_method [FriendlyShipping::ShippingMethod] the shipping method to use
        # @param billing [Symbol] how the shipment is billed (see {BILLING_CODES})
        # @param customer_context [String] a reference to match this request with an order or shipment
        # @param pickup_request_options [PickupRequestOptions] options for the pickup request
        # @param commodity_information_generator [#call] a callable that takes a shipment
        #     and an options object to create an Array of commodity fields as per the UPS docs
        # @param kwargs [Hash]
        # @option kwargs [Array<StructureOptions>] :structure_options the options for structures in the shipment
        # @option kwargs [Class] :structure_options_class the class to use for structure options when none are provided
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in the shipment
        # @option kwargs [Class] :package_options_class the class to use for package options when none are provided
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
