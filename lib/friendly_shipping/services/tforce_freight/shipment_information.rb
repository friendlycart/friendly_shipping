# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Information for a specific shipment returned by the API.
      class ShipmentInformation
        # @return [String] the shipment's BOL ID number
        attr_reader :bol_id

        # @return [String] the shipment's PRO number
        attr_reader :pro_number

        # @return [String] the origin service center
        attr_reader :origin_service_center

        # @return [Boolean] whether or not the email was sent
        attr_reader :email_sent

        # @return [Boolean] whether or not the origin is rural
        attr_reader :origin_is_rural

        # @return [Boolean] whether or not the destination is rural
        attr_reader :destination_is_rural

        # @return [Array<Hash>] the rates
        attr_reader :rates

        # @return [Money] the total charges for this shipment
        attr_reader :total_charges

        # @return [Measured::Weight] the billable weight for this shipment
        attr_reader :billable_weight

        # @return [Integer] the number of days in transit
        attr_reader :days_in_transit

        # @return [Array<ShipmentDocument>] the shipment's documents (BOL, labels, etc)
        attr_reader :documents

        # @return [ShippingMethod] the shipping method
        attr_reader :shipping_method

        # @return [Array<String>] any warnings
        attr_reader :warnings

        # @return [Hash] any additional data
        attr_reader :data

        # @param bol_id [String] the shipment's BOL ID number
        # @param pro_number [String] the shipment's PRO number
        # @param origin_service_center [String] the origin service center
        # @param email_sent [Boolean] whether or not the email was sent
        # @param origin_is_rural [Boolean] whether or not the origin is rural
        # @param destination_is_rural [Boolean] whether or not the destination is rural
        # @param rates [Array<Hash>] the rates
        # @param total_charges [Money] the total charges for this shipment
        # @param billable_weight [Measured::Weight] the billable weight for this shipment
        # @param days_in_transit [Integer] the number of days in transit
        # @param documents [Array<ShipmentDocument>] the shipment's documents (BOL, labels, etc)
        # @param shipping_method [ShippingMethod] the shipping method
        # @param warnings [Array<String>] any warnings
        # @param data [Hash] any additional data
        def initialize(
          bol_id:,
          pro_number: nil,
          origin_service_center: nil,
          email_sent: nil,
          origin_is_rural: nil,
          destination_is_rural: nil,
          rates: [],
          total_charges: nil,
          billable_weight: nil,
          days_in_transit: nil,
          documents: [],
          shipping_method: nil,
          warnings: nil,
          data: {}
        )
          @bol_id = bol_id
          @pro_number = pro_number
          @origin_service_center = origin_service_center
          @email_sent = email_sent
          @origin_is_rural = origin_is_rural
          @destination_is_rural = destination_is_rural
          @rates = rates
          @total_charges = total_charges
          @billable_weight = billable_weight
          @days_in_transit = days_in_transit
          @documents = documents
          @shipping_method = shipping_method
          @warnings = warnings
          @data = data
        end
      end
    end
  end
end
