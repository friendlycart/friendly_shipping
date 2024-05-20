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
              AddressLine1: truncate(location.address1),
              AddressLine2: truncate(location.address2),
              City: clean_city(location.city),
              StateOrProvince: location.region.code,
              ZipOrPostalCode: location.zip,
              CountryCode: location.country.alpha_3_code,
              PhoneNumber: clean_phone(location.phone),
              EmailAddress: location.email
            }.compact
          end

          private

          # R+L does not support periods in city names.
          #
          # @param city [String]
          # @return [String]
          def clean_city(city)
            city.delete(".").strip
          end

          # R+L does not support leading country codes in phone numbers.
          #
          # @param [String] phone
          # @return [String]
          def clean_phone(phone)
            phone.gsub(/^1-/, "").strip
          end

          # @param value [String]
          # @param length [Integer]
          # @return [String]
          def truncate(value, length: 30)
            value && value[0..(length - 1)].strip
          end
        end
      end
    end
  end
end
