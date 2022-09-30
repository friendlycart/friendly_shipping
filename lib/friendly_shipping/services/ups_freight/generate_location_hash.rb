# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GenerateLocationHash
        class << self
          def call(location:)
            {
              Name: location.company_name.presence || location.name,
              Address: {
                AddressLine: address_line(location),
                City: location.city,
                StateProvinceCode: location.region&.code,
                PostalCode: location.zip,
                CountryCode: location.country&.code
              },
              AttentionName: location.name,
              Phone: {
                Number: location.phone
              }.compact.presence
            }.compact
          end

          private

          def address_line(location)
            address_lines = [
              location.address1,
              location.address2,
              location.address3
            ].compact.reject(&:empty?)
            address_lines.size > 1 ? address_lines : address_lines.first
          end
        end
      end
    end
  end
end
