# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Generates the hash for a ship from, ship to or payer location in UPS Freight requests.
      class GenerateLocationHash
        class << self
          # @param location [Physical::Location] the location to serialize
          # @return [Hash] the location hash, with values truncated to the lengths used here
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

          # @param location [Physical::Location]
          # @return [Array<String>, String, nil] an array if there is more than one address line, otherwise a single line
          def address_line(location)
            address_lines = [
              location.address1,
              location.address2,
              location.address3
            ].compact.reject(&:empty?).map { |e| truncate(e) }
            address_lines.size > 1 ? address_lines : truncate(address_lines.first)
          end

          # @param value [String, nil] the value to truncate
          # @param length [Integer] the maximum length
          # @return [String, nil] the value cut to at most `length` characters
          def truncate(value, length: 35)
            value && value[0..(length - 1)]
          end
        end
      end
    end
  end
end
