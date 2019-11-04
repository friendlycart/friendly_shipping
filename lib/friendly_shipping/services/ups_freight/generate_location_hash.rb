# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GenerateLocationHash
        class << self
          def call(location:)
            # We ship freight here, which will mostly be used for businesses.
            # If a personal name is given, treat is as the contact person ("AttentionName")
            {
              Name: location.company_name,
              Address: {
                AddressLine: address_line(location),
                City: location.city,
                StateProvinceCode: location.region.code,
                PostalCode: location.zip,
                CountryCode: location.country.code
              },
              AttentionName: location.name
            }
          end

          private

          def address_line(location)
            [
              location.address1,
              location.address2,
              location.address3
            ].compact.
              reject(&:empty?).
              join(", ")
          end
        end
      end
    end
  end
end
