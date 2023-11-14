# frozen_string_literal: true

require 'friendly_shipping/services/ups_freight/shipment_document'

module FriendlyShipping
  module Services
    class UpsFreight
      class ParseShipmentDocument
        REVERSE_DOCUMENT_TYPES = LabelDocumentOptions::DOCUMENT_TYPES.map(&:reverse_each).to_h(&:to_a)

        def self.call(image_data:)
          format_code = image_data.dig("Type", "Code")
          graphic_image_b64 = image_data["GraphicImage"]

          ShipmentDocument.new(
            format: image_data.dig("Format", "Code").downcase.to_sym,
            binary: Base64.decode64(graphic_image_b64),
            document_type: REVERSE_DOCUMENT_TYPES.fetch(format_code)
          )
        end
      end
    end
  end
end
