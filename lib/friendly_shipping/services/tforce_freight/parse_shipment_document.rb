# frozen_string_literal: true

require 'friendly_shipping/services/ups_freight/shipment_document'

module FriendlyShipping
  module Services
    class TForceFreight
      class ParseShipmentDocument
        REVERSE_DOCUMENT_TYPES = DocumentOptions::DOCUMENT_TYPES.map(&:reverse_each).to_h(&:to_a)

        def self.call(image_data:)
          type_code = image_data["type"]
          format = image_data["format"]
          status = image_data["status"]
          data = image_data["data"]

          ShipmentDocument.new(
            document_type: REVERSE_DOCUMENT_TYPES.fetch(type_code),
            document_format: format.downcase.to_sym,
            status: status,
            binary: Base64.decode64(data)
          )
        end
      end
    end
  end
end
