# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class LabelOptions < RatesOptions
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

        attr_reader :document_options,
                    :email_options,
                    :pickup_options,
                    :delivery_options,
                    :pickup_instructions,
                    :delivery_instructions,
                    :handling_instructions,
                    :reference_numbers

        # @param [Array] reference_numbers Reference numbers for the Bill of Lading
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
          super kwargs
        end

        private

        def fill_codes(reference_numbers)
          reference_numbers.each do |reference_number|
            reference_number[:code] = REFERENCE_NUMBER_CODES.fetch(reference_number[:code])
          end
        end
      end
    end
  end
end
