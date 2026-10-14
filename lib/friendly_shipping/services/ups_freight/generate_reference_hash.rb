# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Generates the Reference hash for the Bill of Lading in UPS Freight ship requests.
      class GenerateReferenceHash
        class << self
          # @param reference_numbers [Array<Hash>, nil] Reference numbers for the Bill of Lading, each with :code and :value
          # @return [Hash] Reference hash suitable for JSON request, empty if there are no reference numbers
          def call(reference_numbers:)
            return {} unless reference_numbers

            references = reference_numbers.map do |reference_number|
              {
                Number: {
                  Code: reference_number[:code],
                  Value: reference_number[:value]
                }
              }
            end
            references.any? ? { Reference: references } : {}
          end
        end
      end
    end
  end
end
