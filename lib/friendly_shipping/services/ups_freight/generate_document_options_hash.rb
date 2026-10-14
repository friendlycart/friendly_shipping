# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Generates the hash describing a requested label or document image for UPS Freight ship requests.
      class GenerateDocumentOptionsHash
        # @param document_options [LabelDocumentOptions] the document options
        # @return [Hash] the document image hash
        def self.call(document_options:)
          {
            Type: {
              Code: document_options.document_type_code
            },
            LabelsPerPage: document_options.labels_per_page,
            Format: {
              Code: document_options.format_code
            },
            PrintFormat: {
              Code: document_options.thermal_code,
            },
            PrintSize: {
              Length: document_options.length,
              Width: document_options.width,
            }
          }
        end
      end
    end
  end
end
