# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Serialize a physical location for use in an R+L API call.
      class SerializeLocation
        class << self
          # @param [Physical::Location] location
          # @return [Hash]
          def call(location)
            {
              CompanyName: location.company_name.presence || location.name,
              AddressLine1: location.address1,
              AddressLine2: location.address2,
              City: location.city,
              StateOrProvince: location.region.code,
              ZipOrPostalCode: location.zip,
              CountryCode: location.country.alpha_3_code,
              PhoneNumber: clean_phone(location.phone),
              EmailAddress: location.email
            }.compact
          end

          private

          # RL does not support leading country codes in phone numbers.
          #
          # @param [String] phone
          # @return [String]
          def clean_phone(phone)
            phone.gsub(/^1-/, "")
          end
        end
      end
    end
  end
end
