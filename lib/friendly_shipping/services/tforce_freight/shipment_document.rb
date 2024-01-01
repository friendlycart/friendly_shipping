# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # A shipping document (BOL, label, etc.) returned by the API.
      class ShipmentDocument
        # @return [String] the type of document
        attr_reader :document_type

        # @return [String] the format of the document
        attr_reader :document_format

        # @return [String] the document's binary data
        attr_reader :binary

        # @return [String] the status of the document
        attr_reader :status

        # @param document_type [String] the type of document
        # @param document_format [String] the format of the document
        # @param binary [String] the document's binary data
        # @param status [String] the status of the document (defaults to `nil`)
        def initialize(
          document_type:,
          document_format:,
          binary:,
          status: nil
        )
          @document_type = document_type
          @document_format = document_format
          @binary = binary
          @status = status
        end
      end
    end
  end
end
