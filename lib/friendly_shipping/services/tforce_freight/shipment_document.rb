# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      class ShipmentDocument
        attr_reader :document_type, :document_format, :binary, :status

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
