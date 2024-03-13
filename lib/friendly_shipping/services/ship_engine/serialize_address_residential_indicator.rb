# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      class SerializeAddressResidentialIndicator
        class << self
          # @param location [Physical::Location]
          # @return [Hash]
          def call(location)
            { address_residential_indicator: residential_indicator(location) }
          end

          private

          # @param location [Physical::Location]
          # @return [String]
          def residential_indicator(location)
            return "unknown" if location&.address_type.nil?

            location.address_type == "residential" ? "yes" : "no"
          end
        end
      end
    end
  end
end
