# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class GenerateAddressHash
        class << self
          def call(location:, international: false, shipper_number: nil)
            snippet = {}

            # TODO: is this still the right logic?
            attention_name = location.name if international || location.company_name
            snippet[:AttentionName] = attention_name if attention_name
            snippet[:Name] = (location.company_name || location.name)&.slice(0..34)
            snippet[:ShipperNumber] = shipper_number if shipper_number.present?
            snippet[:PhoneNumber] = location.phone if location.phone
            snippet[:Address] = {
              AddressLine: [location.address1, location.address2, location.address3].compact,
              City: location.city,
              PostalCode: location.zip,
              StateProvinceCode: location.region&.code,
              CountryCode: location.country&.code,
              ResidentialAddressIndicator: location.commercial? ? nil : 'X'
            }.compact
            snippet.compact
          end
        end
      end
    end
  end
end
