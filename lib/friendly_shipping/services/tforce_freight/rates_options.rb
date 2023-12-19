# frozen_string_literal: true

require 'friendly_shipping/services/tforce_freight/rates_package_options'
require 'friendly_shipping/services/tforce_freight/generate_commodity_information'

module FriendlyShipping
  module Services
    class TForceFreight
      # Options for generating TForce Freight rates for a shipment
      #

      # @attribute [Physical::Location] billing_address The billing address
      # @attribute [FriendlyShipping::ShippingMethod] shipping_method The shipping method to use
      # @attribute [Date] pickup_date Date of the Pickup. Defaults to today.
      # @attribute [Symbol] billing One of the keys in the `BILLING_CODES` constant. How the shipment
      #     would be billed.
      # @attribute [String] type Rating call type. Possible values are L, F, or B. Defaults to L.
      # @attribute [Boolean] density_eligible Indicates that the rate request is density based. Defaults to `false`
      # @attribute [Boolean] accessorial_rate Indicates that the rate is accessorial. Defaults to `false`
      # @attribute [Boolean] time_in_transit Requests transit timing information be included in the response. Defaults to `true`
      # @attribute [Boolean] quote_number Requests a quote number be included in the response. Defaults to `false`
      # @attribute [String] customer_context A reference to match this request with an order or shipment. Defaults to `nil`
      # @attribute [Array<String>] pickup_options Shipment pick up service options
      # @attribute [Array<String] delivery_options Shipment delivery service options
      # @attribute [Callable] commodity_information_generator A callable that takes a shipment
      #     and an options object to create an Array of commodity fields as per the UPS docs.
      # @attribute [RatesPackageOptions] package_options Options for each of the packages/pallets in this shipment
      class RatesOptions < FriendlyShipping::ShipmentOptions
        BILLING_CODES = {
          prepaid: "10",
          third_party: "30",
          freight_collect: "40"
        }.freeze

        TYPE_CODES = {
          l: "L",
          f: "F",
          b: "B"
        }.freeze

        PICKUP_OPTIONS = {
          inside: "INPU",
          liftgate: "LIFO",
          residential: "RESP",
          limited_access: "LAPU"
        }.freeze

        DELIVERY_OPTIONS = {
          inside: "INDE",
          liftgate: "LIFD",
          residential: "RESD",
          limited_access: "LADL"
        }.freeze

        attr_reader :billing_address,
                    :shipping_method,
                    :pickup_date,
                    :billing_code,
                    :type_code,
                    :density_eligible,
                    :accessorial_rate,
                    :time_in_transit,
                    :quote_number,
                    :pickup_options,
                    :delivery_options,
                    :customer_context,
                    :commodity_information_generator

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

          super(**kwargs.merge(package_options_class: RatesPackageOptions))
        end

        private

        def validate_pickup_options!
          invalid_options = (pickup_options - PICKUP_OPTIONS.values)
          return unless invalid_options.any?

          raise ArgumentError, "Invalid pickup option(s): #{invalid_options.join(', ')}"
        end

        def validate_delivery_options!
          invalid_options = (delivery_options - DELIVERY_OPTIONS.values)
          return unless invalid_options.any?

          raise ArgumentError, "Invalid delivery option(s): #{invalid_options.join(', ')}"
        end
      end
    end
  end
end
