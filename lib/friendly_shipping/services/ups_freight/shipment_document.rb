# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # A document (for example a label or bill of lading) returned for a UPS Freight shipment.
      class ShipmentDocument
        # @return [Symbol] the document format, for example :pdf
        attr_reader :format

        # @return [Symbol] the document type (a key of {LabelDocumentOptions::DOCUMENT_TYPES})
        attr_reader :document_type

        # @return [String] the decoded document data
        attr_reader :binary

        # @param format [Symbol] the document format
        # @param document_type [Symbol] the document type
        # @param binary [String] the decoded document data
        def initialize(
          format:,
          document_type:,
          binary:
        )
          @format = format
          @document_type = document_type
          @binary = binary
        end
      end
    end
  end
end
