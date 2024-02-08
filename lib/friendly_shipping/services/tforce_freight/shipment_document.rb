# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      class ShipmentDocument
        attr_reader :document_type, :document_format, :status, :binary

        def initialize(
          document_type:,
          document_format:,
          status:,
          binary:
        )
          @document_type = document_type
          @document_format = document_format
          @status = status
          @binary = binary
        end
      end
    end
  end
end
