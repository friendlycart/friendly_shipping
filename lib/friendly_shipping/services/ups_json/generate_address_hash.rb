# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Generates the hash representing an address (shipper, ship to, ship from) in UPS request payloads.
      class GenerateAddressHash
        class << self
          # @param location [Physical::Location] the location to convert
          # @param international [Boolean] whether the shipment is international. If true, the location's name is
          #   always used as the attention name.
          # @param shipper_number [String, nil] the UPS shipper number to include, if any
          # @return [Hash] the address hash, with nil values removed
          def call(location:, international: false, shipper_number: nil)
            snippet = {}

            attention_name = location.name if international || location.company_name
            snippet[:AttentionName] = attention_name if attention_name
            snippet[:Name] = (location.company_name || location.name)&.slice(0..34)
            snippet[:ShipperNumber] = shipper_number if shipper_number.present?
            snippet[:Phone] = { Number: location.phone } if location.phone
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
