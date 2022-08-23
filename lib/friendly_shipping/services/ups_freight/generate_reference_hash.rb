# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GenerateReferenceHash
        class << self
          # @param [Array] reference_numbers Reference numbers for the Bill of Lading
          # @return [Hash] Reference hash suitable for JSON request
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
