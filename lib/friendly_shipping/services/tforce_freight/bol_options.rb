# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Options for creating a Bill of Lading (BOL).
      class BOLOptions < FriendlyShipping::ShipmentOptions
        # Maps friendly names to billing codes.
        BILLING_CODES = {
          prepaid: "10",
          third_party: "30",
          freight_collect: "40"
        }.freeze

        # Maps friendly names to reference number codes.
        REFERENCE_NUMBER_CODES = {
          bill_of_lading_number: "BL",
          purchase_order_number: "PO",
          shipper_reference: "SH",
          consignee_reference: "CO",
          pm: "PM",
          proj: "PROJ",
          quote: "QUOTE",
          sid: "SID",
          task: "TASK",
          vprc: "VPRC",
          other: "OTHER"
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

        # @return [String] the service code to use
        attr_reader :service_code

        # @return [Time] date/time of pickup
        attr_reader :pickup_at

        # @return [Range] time window for pickup
        attr_reader :pickup_time_window

        # @return [Boolean] whether to preview rates in the response
        attr_reader :preview_rate

        # @return [Boolean] whether to include time in transit in the response
        attr_reader :time_in_transit

        # @return [String] code indicating how to bill this shipment (see {BILLING_CODES})
        attr_reader :billing_code

        # @return [Array<Hash>] reference numbers for this shipment (see {REFERENCE_NUMBER_CODES})
        attr_reader :reference_numbers

        # @return [String] instructions for pickup
        attr_reader :pickup_instructions

        # @return [String] instructions for handling
        attr_reader :handling_instructions

        # @return [String] instructions for delivery
        attr_reader :delivery_instructions

        # @return [Array<String>] options for pickup (see {PICKUP_OPTIONS})
        attr_reader :pickup_options

        # @return [Array<String>] options for delivery (see {DELIVERY_OPTIONS})
        attr_reader :delivery_options

        # @return [Array<DocumentOptions>] options for documents
        attr_reader :document_options

        # @return [Proc, #call] the callable used generate commodity information
        attr_reader :commodity_information_generator

        # @param service_code [String] the service code to use
        # @param pickup_at [Time] date/time of pickup (defaults to now)
        # @param pickup_time_window [Range] time window for pickup (defaults to start/end of today)
        # @param preview_rate [Boolean] whether to preview rates in the response
        # @param time_in_transit [Boolean] whether to include time in transit in the response
        # @param billing [Symbol] how to bill this shipment (see {BILLING_CODES})
        # @param reference_numbers [Array<Hash>] reference numbers for this shipment (see {REFERENCE_NUMBER_CODES})
        # @param pickup_instructions [String] instructions for pickup
        # @param handling_instructions [String] instructions for handling
        # @param delivery_instructions [String] instructions for delivery
        # @param pickup_options [Array<String>] options for pickup (see {PICKUP_OPTIONS})
        # @param delivery_options [Array<String>] options for delivery (see {DELIVERY_OPTIONS})
        # @param document_options [Array<DocumentOptions>] options for documents
        # @param commodity_information_generator [Proc, #call] the callable used generate commodity information
        # @param kwargs [Hash]
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this shipment
        # @option kwargs [Class] :package_options_class the class to use for package options when none are provided
        def initialize(
          service_code: FriendlyShipping::Services::TForceFreight::SHIPPING_METHODS.first.service_code,
          pickup_at: Time.now,
          pickup_time_window: Time.now.beginning_of_day..Time.now.end_of_day,
          preview_rate: false,
          time_in_transit: false,
          billing: :prepaid,
          reference_numbers: [],
          pickup_instructions: nil,
          handling_instructions: nil,
          delivery_instructions: nil,
          pickup_options: [],
          delivery_options: [],
          document_options: [],
          commodity_information_generator: GenerateCommodityInformation,
          **kwargs
        )
          @service_code = service_code
          @pickup_at = pickup_at
          @pickup_time_window = pickup_time_window
          @preview_rate = preview_rate
          @time_in_transit = time_in_transit
          @billing_code = BILLING_CODES.fetch(billing)
          @reference_numbers = fill_codes(reference_numbers)
          @pickup_instructions = pickup_instructions
          @handling_instructions = handling_instructions
          @delivery_instructions = delivery_instructions
          @pickup_options = pickup_options
          @delivery_options = delivery_options
          @document_options = document_options
          @commodity_information_generator = commodity_information_generator

          validate_pickup_options!
          validate_delivery_options!

          super(**kwargs.reverse_merge(package_options_class: RatesPackageOptions))
        end

        private

        # @param reference_numbers [Array<Hash>]
        # @return [Array<Hash>]
        def fill_codes(reference_numbers)
          reference_numbers.each do |reference_number|
            reference_number[:code] = REFERENCE_NUMBER_CODES.fetch(reference_number[:code])
          end
        end

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
