# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Generates a document options hash for JSON serialization.
      class GenerateDocumentOptionsHash
        class << self
          # @param document_options [DocumentOptions] the document options
          # @return [Hash] document options hash suitable for JSON request
          def call(document_options:)
            {
              type: document_options.document_type_code,
              format: document_options.format_code,
              label: label(document_options)
            }.compact
          end

          private

          # @param document_options [DocumentOptions] the document options
          # @return [Hash, nil] label hash or nil if this is a BOL
          def label(document_options)
            return unless document_options.type == :label

            {
              type: document_options.label_type_code,
              startPosition: document_options.start_position,
              numberOfStickers: document_options.number_of_stickers
            }
          end
        end
      end
    end
  end
end
