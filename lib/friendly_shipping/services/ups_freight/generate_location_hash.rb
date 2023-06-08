# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GenerateLocationHash
        class << self
          def call(location:)
            {
              Name: truncate(location.company_name.presence || location.name),
              Address: {
                AddressLine: address_line(location),
                City: truncate(location.city, length: 29),
                StateProvinceCode: location.region&.code,
                PostalCode: location.zip,
                CountryCode: location.country&.code
              },
              AttentionName: truncate(location.name),
              Phone: {
                Number: truncate(location.phone, length: 14)
              }.compact.presence
            }.compact
          end

          private

          def address_line(location)
            address_lines = [
              location.address1,
              location.address2,
              location.address3
            ].compact.reject(&:empty?).map { |e| truncate(e) }
            address_lines.size > 1 ? address_lines : truncate(address_lines.first)
          end

          def truncate(value, length: 35)
            value && value[0..(length - 1)]
          end
        end
      end
    end
  end
end
