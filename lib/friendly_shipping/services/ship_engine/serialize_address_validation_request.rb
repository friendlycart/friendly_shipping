# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      class SerializeAddressValidationRequest
        class << self
          # @param location [Physical::Location]
          # @return [Array<Hash>]
          def call(location:)
            [
              {
                name: location.name,
                phone: location.phone,
                email: location.email,
                company_name: location.company_name,
                address_line1: location.address1,
                address_line2: location.address2,
                address_line3: location.address3,
                city_locality: location.city,
                state_province: location.region&.code,
                postal_code: location.zip,
                country_code: location.country&.code
              }.merge(SerializeAddressResidentialIndicator.call(location))
            ]
          end
        end
      end
    end
  end
end
