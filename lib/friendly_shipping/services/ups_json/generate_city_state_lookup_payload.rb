# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class GenerateCityStateLookupPayload
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
