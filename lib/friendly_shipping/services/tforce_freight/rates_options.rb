# frozen_string_literal: true

require 'friendly_shipping/services/tforce_freight/rates_package_options'
require 'friendly_shipping/services/tforce_freight/generate_commodity_information'

module FriendlyShipping
  module Services
    class TForceFreight
      # Options for getting rates for a shipment.
      class RatesOptions < ShipmentOptions
        # Maps friendly names to billing codes.
        BILLING_CODES = {
          prepaid: "10",
          third_party: "30",
          freight_collect: "40"
        }.freeze

        # Maps friendly names to type codes.
        TYPE_CODES = {
          l: "L", # LTL (Less Than Truckload) only
          f: "F", # GFP (Ground w/Freight Pricing) only
          b: "B"  # Both (LTL and GFP)
        }.freeze

        # Maps friendly names to pickup options.
        PICKUP_OPTIONS = {
          inside: "INPU",
          liftgate: "LIFO",
          limited_access: "LAPU",
          holiday: "WHPU",
          weekend: "WHPU",
          tradeshow: "TRPU",
          residential: "RESP"
        }.freeze

        # Maps friendly names to delivery options.
        DELIVERY_OPTIONS = {
          inside: "INDE",
          liftgate: "LIFD",
          limited_access: "LADL",
          holiday: "WHDL",
          weekend: "WHDL",
          call_consignee: "NTFN",
          tradeshow: "TRDS",
          residential: "RESD"
        }.freeze

        # @return [Physical::Location] the billing address
        attr_reader :billing_address

        # @return [ShippingMethod] the shipping method
        attr_reader :shipping_method

        # @return [Date] date of the pickup
        attr_reader :pickup_date

        # @return [Symbol] how the shipment is billed (see {BILLING_CODES})
        attr_reader :billing_code

        # @return [String] rating call type (see {TYPE_CODES})
        attr_reader :type_code

        # @return [Boolean] indicates that the rate request is density based
        attr_reader :density_eligible

        # @return [Boolean] indicates that the rate is accessorial
        attr_reader :accessorial_rate

        # @return [Boolean] requests transit timing information be included in the response
        attr_reader :time_in_transit

        # @return [Boolean] requests a quote number be included in the response
        attr_reader :quote_number

        # @return [Array<String>] shipment pick up service options (see {PICKUP_OPTIONS})
        attr_reader :pickup_options

        # @return [Array<String] shipment delivery service options (see {DELIVERY_OPTIONS})
        attr_reader :delivery_options

        # @return [String] customer context
        attr_reader :customer_context

        # @return [Callable] a callable that takes a shipment
        attr_reader :commodity_information_generator

        # @param billing_address [Physical::Location] the billing address
        # @param shipping_method [ShippingMethod] the shipping method to use
        # @param pickup_date [Date] date of the pickup (defaults to today)
        # @param billing [Symbol] how the shipment is billed (see {BILLING_CODES})
        # @param type [String] rating call type (defaults to L, see {TYPE_CODES})
        # @param density_eligible [Boolean] indicates that the rate request is density based (defaults to `false`)
        # @param accessorial_rate [Boolean] indicates that the rate is accessorial (defaults to `false`)
        # @param time_in_transit [Boolean] requests transit timing information be included in the response (defaults to `true`)
        # @param quote_number [Boolean] requests a quote number be included in the response (defaults to `false`)
        # @param pickup_options [Array<String>] shipment pick up service options (see {PICKUP_OPTIONS})
        # @param delivery_options [Array<String] shipment delivery service options (see {DELIVERY_OPTIONS})
        # @param customer_context [String] a reference to match this request with an order or shipment (defaults to `nil`)
        # @param commodity_information_generator [Callable] a callable that takes a shipment
        #     and an options object to create an `Array` of commodity fields as per the UPS docs
        # @param kwargs [Hash]
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this shipment
        # @option kwargs [Class] :package_options_class the class to use for package options when none are provided
        def initialize(
          billing_address:,
          shipping_method:,
          pickup_date: Date.today,
          billing: :prepaid,
          type: :l,
          density_eligible: false,
          accessorial_rate: false,
          time_in_transit: true,
          quote_number: false,
          pickup_options: [],
          delivery_options: [],
          customer_context: nil,
          commodity_information_generator: GenerateCommodityInformation,
          **kwargs
        )
          @pickup_date = pickup_date
          @billing_address = billing_address
          @billing_code = BILLING_CODES.fetch(billing)
          @shipping_method = shipping_method
          @type_code = TYPE_CODES.fetch(type)
          @density_eligible = density_eligible
          @accessorial_rate = accessorial_rate
          @time_in_transit = time_in_transit
          @quote_number = quote_number
          @pickup_options = pickup_options
          @delivery_options = delivery_options
          @customer_context = customer_context
          @commodity_information_generator = commodity_information_generator

          validate_pickup_options!
          validate_delivery_options!

          super(**kwargs.reverse_merge(package_options_class: PackageOptions))
        end

        private

        # @raise [ArgumentError] invalid pickup options
        # @return [nil]
        def validate_pickup_options!
          invalid_options = (pickup_options - PICKUP_OPTIONS.values)
          return unless invalid_options.any?

          raise ArgumentError, "Invalid pickup option(s): #{invalid_options.join(', ')}"
        end

        # @raise [ArgumentError] invalid delivery options
        # @return [nil]
        def validate_delivery_options!
          invalid_options = (delivery_options - DELIVERY_OPTIONS.values)
          return unless invalid_options.any?

          raise ArgumentError, "Invalid delivery option(s): #{invalid_options.join(', ')}"
        end
      end
    end
  end
end
