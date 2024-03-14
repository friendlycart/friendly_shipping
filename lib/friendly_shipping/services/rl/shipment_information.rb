# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Represents information for a specific shipment. This includes one or more
      # documents, a PRO number, and a pickup request number.
      class ShipmentInformation
        # @return [String] the shipment's PRO number
        attr_reader :pro_number

        # @return [String] the shipment's pickup request number
        attr_reader :pickup_request_number

        # @return [Array<ShipmentDocument>] the shipment's documents
        attr_reader :documents

        # @param pro_number [String] the shipment's PRO number
        # @param pickup_request_number [String] the shipment's pickup request number
        # @param documents [Array<ShipmentDocument>] the shipment's documents (BOL, labels, etc)
        def initialize(
          pro_number:,
          pickup_request_number: nil,
          documents: []
        )
          @pro_number = pro_number
          @pickup_request_number = pickup_request_number
          @documents = documents
        end

        # Returns true if PRO number and pickup request number are present.
        # Returns false if either of these values are missing.
        #
        # @return [Boolean]
        def valid?
          pro_number.present? && pickup_request_number.present?
        end
      end
    end
  end
end
