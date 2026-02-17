# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Represents a load detail returned from a GetLoadInfo response.
      class LoadInfo
        # @return [Integer] the load ID
        attr_reader :load_id

        # @return [String, nil] the ship date
        attr_reader :ship_date

        # @return [String, nil] the carrier booked (SCAC or name)
        attr_reader :carrier_booked

        # @return [String, nil] the PRO number
        attr_reader :pro_number

        # @return [String, nil] the confirmation number
        attr_reader :confirmation_number

        # @return [String, nil] the tracking link URL
        attr_reader :tracking_link

        # @return [String, nil] the load status detail
        attr_reader :load_status_detail

        # @return [String, nil] the billing ID
        attr_reader :billing_id

        # @return [String, nil] the PO number
        attr_reader :po_number

        # @return [String, nil] the custom ID
        attr_reader :custom_id

        # @return [String, nil] the customer billing
        attr_reader :customer_billing

        # @return [Hash, nil] origin location info
        attr_reader :origin_info

        # @return [Hash, nil] destination location info
        attr_reader :destination_info

        # @return [Numeric, nil] total weight
        attr_reader :total_weight

        # @return [Integer, nil] total shipping quantity
        attr_reader :total_shipping_qty

        # @return [String, nil] shipping unit type
        attr_reader :shipping_unit

        # @return [String, nil] special instructions
        attr_reader :special_instructions

        # @return [String, nil] notes
        attr_reader :notes

        # @return [String, nil] load status ID
        attr_reader :load_status_id

        # @return [String, nil] the delivery date
        attr_reader :delivery_date

        # @return [Numeric, nil] customer charge
        attr_reader :cust_charge

        # @return [Numeric, nil] freight charge
        attr_reader :freight_charge

        # @return [Numeric, nil] accessorial charges
        attr_reader :access

        # @return [Numeric, nil] base charge
        attr_reader :base

        # @return [Numeric, nil] fuel surcharge
        attr_reader :fsc

        # @return [Numeric, nil] insurance fee
        attr_reader :insurance_fee

        # @return [Numeric, nil] mileage
        attr_reader :mileage

        # @return [Array<Hash>] tracking status events
        attr_reader :tracking_status

        # @return [Array<Document>] documents (BOL, shipping labels, etc.)
        attr_reader :documents

        def initialize(
          load_id: nil,
          ship_date: nil,
          carrier_booked: nil,
          pro_number: nil,
          confirmation_number: nil,
          tracking_link: nil,
          load_status_detail: nil,
          billing_id: nil,
          po_number: nil,
          custom_id: nil,
          customer_billing: nil,
          origin_info: nil,
          destination_info: nil,
          total_weight: nil,
          total_shipping_qty: nil,
          shipping_unit: nil,
          special_instructions: nil,
          notes: nil,
          load_status_id: nil,
          delivery_date: nil,
          cust_charge: nil,
          freight_charge: nil,
          access: nil,
          base: nil,
          fsc: nil,
          insurance_fee: nil,
          mileage: nil,
          tracking_status: [],
          documents: []
        )
          @load_id = load_id
          @ship_date = ship_date
          @carrier_booked = carrier_booked
          @pro_number = pro_number
          @confirmation_number = confirmation_number
          @tracking_link = tracking_link
          @load_status_detail = load_status_detail
          @billing_id = billing_id
          @po_number = po_number
          @custom_id = custom_id
          @customer_billing = customer_billing
          @origin_info = origin_info
          @destination_info = destination_info
          @total_weight = total_weight
          @total_shipping_qty = total_shipping_qty
          @shipping_unit = shipping_unit
          @special_instructions = special_instructions
          @notes = notes
          @load_status_id = load_status_id
          @delivery_date = delivery_date
          @cust_charge = cust_charge
          @freight_charge = freight_charge
          @access = access
          @base = base
          @fsc = fsc
          @insurance_fee = insurance_fee
          @mileage = mileage
          @tracking_status = tracking_status
          @documents = documents
        end
      end
    end
  end
end
