# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Information returned by UPS Freight for a shipment that was booked.
      class ShipmentInformation
        # @return [Array<ShipmentDocument>] the documents returned for the shipment
        attr_reader :documents

        # @return [String, nil] the PRO number
        attr_reader :pro_number

        # @return [String, nil] the pickup request confirmation number
        attr_reader :pickup_request_number

        # @return [Money, nil] the total shipment charge
        attr_reader :total

        # @return [String] the bill of lading ID
        attr_reader :bol_id

        # @return [ShippingMethod, nil] the shipping method of the shipment
        attr_reader :shipping_method

        # @return [String, nil] warnings returned with the response
        attr_reader :warnings

        # @return [Hash] additional data, such as the cost breakdown
        attr_reader :data

        # Backwards compatibility after renaming this attribute
        alias_method :number, :pro_number

        # @param total [Money, nil] the total shipment charge
        # @param bol_id [String] the bill of lading ID
        # @param number [String, nil] deprecated alias for pro_number
        # @param pro_number [String, nil] the PRO number
        # @param pickup_request_number [String, nil] the pickup request confirmation number
        # @param documents [Array<ShipmentDocument>] the documents returned for the shipment
        # @param shipping_method [ShippingMethod, nil] the shipping method of the shipment
        # @param warnings [String, nil] warnings returned with the response
        # @param data [Hash] additional data, such as the cost breakdown
        def initialize(
          total:,
          bol_id:,
          number: nil,
          pro_number: nil,
          pickup_request_number: nil,
          documents: [],
          shipping_method: nil,
          warnings: nil,
          data: {}
        )
          @total = total
          @bol_id = bol_id
          @pro_number = pro_number || number
          @pickup_request_number = pickup_request_number
          @documents = documents
          @shipping_method = shipping_method
          @warnings = warnings
          @data = data
        end
      end
    end
  end
end
