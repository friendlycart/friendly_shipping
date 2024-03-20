# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Options for generating UPS Freight labels for a shipment.
      class LabelOptions < RatesOptions
        # Maps friendly names to reference number codes.
        REFERENCE_NUMBER_CODES = {
          bill_of_lading_number: "57",
          purchase_order_number: "28",
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

        # @return [Array<LabelDocumentOptions>]
        attr_reader :document_options

        # @return [Array<LabelEmailOptions>]
        attr_reader :email_options

        # @return [LabelPickupOptions]
        attr_reader :pickup_options

        # @return [LabelDeliveryOptions]
        attr_reader :delivery_options

        # @return [String]
        attr_reader :pickup_instructions

        # @return [String]
        attr_reader :delivery_instructions

        # @return [String]
        attr_reader :handling_instructions

        # @return [Array<Hash>]
        attr_reader :reference_numbers

        # @param document_options [Array<LabelDocumentOptions>]
        # @param email_options [Array<LabelEmailOptions>]
        # @param pickup_options [LabelPickupOptions]
        # @param delivery_options [LabelDeliveryOptions]
        # @param pickup_instructions [String]
        # @param delivery_instructions [String]
        # @param handling_instructions [String]
        # @param reference_numbers [Array<Hash>] reference numbers for the Bill of Lading
        def initialize(
          document_options: [],
          email_options: [],
          pickup_options: nil,
          delivery_options: nil,
          pickup_instructions: nil,
          delivery_instructions: nil,
          handling_instructions: nil,
          reference_numbers: [],
          **kwargs
        )
          @pickup_options = pickup_options
          @delivery_options = delivery_options
          @document_options = document_options
          @email_options = email_options
          @pickup_instructions = pickup_instructions
          @delivery_instructions = delivery_instructions
          @handling_instructions = handling_instructions
          @reference_numbers = fill_codes(reference_numbers)
          super(**kwargs.reverse_merge(package_options_class: LabelPackageOptions))
        end

        private

        # @param reference_numbers [Array<Hash>] reference numbers for the Bill of Lading
        # @return [Array<Hash>] reference numbers with codes filled
        def fill_codes(reference_numbers)
          reference_numbers.each do |reference_number|
            reference_number[:code] = REFERENCE_NUMBER_CODES.fetch(reference_number[:code])
          end
        end
      end
    end
  end
end
