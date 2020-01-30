# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class ShipmentDocument
        attr_reader :format, :document_type, :binary

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
