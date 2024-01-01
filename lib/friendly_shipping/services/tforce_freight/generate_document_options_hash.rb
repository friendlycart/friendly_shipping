# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Generates a document options hash for JSON serialization.
      class GenerateDocumentOptionsHash
        # @param document_options [DocumentOptions] the document options
        # @return [Hash] document options hash suitable for JSON request
        def self.call(document_options:)
          {
            type: document_options.document_type_code,
            format: document_options.format_code,
            label: {
              type: document_options.thermal_code,
              startPosition: document_options.start_position,
              numberOfStickers: document_options.number_of_stickers
            }
          }
        end
      end
    end
  end
end
