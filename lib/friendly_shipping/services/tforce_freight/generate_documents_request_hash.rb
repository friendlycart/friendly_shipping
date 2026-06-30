# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Generates a request hash for getting documents by PRO number.
      class GenerateDocumentsRequestHash
        # Maps friendly names to TForce document category codes.
        DOCUMENT_CATEGORIES = {
          bill_of_lading: "BOL",
          claims: "CLM",
          delivery_receipt: "DR",
          invoice: "INVC",
          weight_certificate: "WGHT"
        }.freeze

        class << self
          # @param pro [String] the 9-digit PRO number
          # @param document_categories [Array<Symbol>] the categories to retrieve (see {DOCUMENT_CATEGORIES})
          # @return [Hash]
          def call(pro:, document_categories:)
            {
              pro: pro,
              documentCategories: document_categories.map { |category| DOCUMENT_CATEGORIES.fetch(category) }
            }
          end
        end
      end
    end
  end
end
