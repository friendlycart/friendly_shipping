# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Generates a reference hash for JSON serialization.
      class GenerateReferenceHash
        class << self
          # @param reference_numbers [Array] reference numbers for the Bill of Lading
          # @return [Hash] reference hash suitable for JSON request
          def call(reference_numbers:)
            return {} unless reference_numbers

            references = reference_numbers.map do |reference_number|
              {
                number: reference_number[:value],
                type: reference_number[:code],
                quantity: reference_number[:quantity],
                weight: reference_number[:weight]
              }.compact
            end
            references.any? ? { references: references } : {}
          end
        end
      end
    end
  end
end
