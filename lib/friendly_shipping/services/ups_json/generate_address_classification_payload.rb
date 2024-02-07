# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class GenerateAddressClassificationPayload
        def self.call(location:)
          {
            XAVRequest: {
              Request: {
                RequestOption: '2', # Address Classification, duplicated in the url path
              },
              AddressKeyFormat: [
                {
                  AddressLine: [location.address1, location.address2, location.address3].compact,
                  ConsigneeName: location.company_name || location.name,
                  CountryCode: location.country.code,
                  PoliticalDivision1: location.region.name,
                  PoliticalDivision2: location.city,
                  PostcodePrimaryLow: location.zip
                }
              ]
            }
          }
        end
      end
    end
  end
end
