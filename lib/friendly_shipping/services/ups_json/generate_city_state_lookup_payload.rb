# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Generates the request payload for looking up the city and state of a ZIP code.
      class GenerateCityStateLookupPayload
        # @param location [Physical::Location] a location with ZIP code and country set
        # @return [Hash] the XAVRequest payload
        def self.call(location:)
          {
            XAVRequest: {
              RegionalRequestIndicator: "1",
              AddressKeyFormat: [
                {
                  PostcodePrimaryLow: location.zip,
                  CountryCode: location.country.code
                }
              ]
            }
          }
        end
      end
    end
  end
end
