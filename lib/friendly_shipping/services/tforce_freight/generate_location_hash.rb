# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Generates a location hash for JSON serialization.
      class GenerateLocationHash
        class << self
          # @param location [Physical::Location] the location
          # @return [Hash] location hash suitable for JSON request
          def call(location:)
            {
              address: {
                city: location.city,
                stateProvinceCode: location.region&.code,
                postalCode: location.zip&.strip&.[](0..4),
                country: location.country&.code
              }.compact
            }
          end
        end
      end
    end
  end
end
