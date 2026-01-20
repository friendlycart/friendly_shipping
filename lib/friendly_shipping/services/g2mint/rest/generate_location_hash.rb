# frozen_string_literal: true

module FriendlyShipping
  module Services
    class G2Mint
      module REST
        # Generates a location hash for G2Mint API requests.
        class GenerateLocationHash
          class << self
            # @param location [Physical::Location] the location
            # @return [Hash] location hash for G2Mint API
            def call(location:)
              {
                address1: location.address1,
                address2: location.address2,
                city: location.city,
                stateProvince: location.region&.code,
                postalCode: location.zip,
                country: location.country&.code,
                latitude: location.latitude,
                longitude: location.longitude
              }.compact
            end
          end
        end
      end
    end
  end
end
