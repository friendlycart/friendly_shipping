# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      class GenerateLocationHash
        class << self
          def call(location:)
            {
              address: {
                city: location.city,
                stateProvinceCode: location.region&.code,
                postalCode: location.zip,
                country: location.country&.code
              }.compact
            }
          end
        end
      end
    end
  end
end
