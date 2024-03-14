# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Represents an R+L shipment document such as a BOL or shipping label.
      class ShipmentDocument
        # @return [String] the format of the document's binary data
        attr_reader :format

        # @return [String] the type of document
        attr_reader :document_type

        # @return [String] the document's binary data
        attr_reader :binary

        # @param format [String] the format of the document's binary data
        # @param document_type [String] the type of document
        # @param binary [String] the document's binary data
        def initialize(
          format:,
          document_type:,
          binary:
        )
          @format = format
          @document_type = document_type
          @binary = binary
        end

        # Returns true if format, document type, and binary data are all present.
        # Returns false if any of these values are missing.
        #
        # @return [Boolean]
        def valid?
          format.present? && document_type.present? && binary.present?
        end
      end
    end
  end
end
