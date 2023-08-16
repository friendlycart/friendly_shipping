# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      class ShipmentDocument
        attr_reader :format, :document_type, :binary

        # @param [String] format The format of the binary data
        # @param [String] document_type The type of document
        # @param [String] binary The binary data
        def initialize(
          format:,
          document_type:,
          binary:
        )
          @format = format
          @document_type = document_type
          @binary = binary
        end

        # @return [Boolean]
        def valid?
          format.present? && document_type.present? && binary.present?
        end
      end
    end
  end
end
