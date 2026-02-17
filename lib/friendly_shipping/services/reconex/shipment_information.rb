# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Represents information returned from a CreateLoad response.
      class ShipmentInformation
        # @return [String] the load ID
        attr_reader :load_id

        # @return [String] the PRO number
        attr_reader :pro_number

        # @return [String] the billing ID
        attr_reader :billing_id

        # @return [String] the custom ID
        attr_reader :custom_id

        # @return [String] the PO number
        attr_reader :po_number

        # @return [String] the customer billing
        attr_reader :customer_billing

        # @param load_id [String] the load ID
        # @param pro_number [String] the PRO number
        # @param billing_id [String] the billing ID
        # @param custom_id [String] the custom ID
        # @param po_number [String] the PO number
        # @param customer_billing [String] the customer billing
        def initialize(
          load_id: nil,
          pro_number: nil,
          billing_id: nil,
          custom_id: nil,
          po_number: nil,
          customer_billing: nil
        )
          @load_id = load_id
          @pro_number = pro_number
          @billing_id = billing_id
          @custom_id = custom_id
          @po_number = po_number
          @customer_billing = customer_billing
        end

        # Returns true if load_id is present.
        #
        # @return [Boolean]
        def valid?
          load_id.present?
        end
      end
    end
  end
end
