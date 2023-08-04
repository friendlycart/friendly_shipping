# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      class SerializeTransitTimesRequest
        class << self
          # @param [Physical::Shipment] shipment
          # @param [FriendlyShipping::Services::RL::QuoteOptions] options
          # @return [Hash]
          def call(shipment:, options:)
            {
              PickupDate: options.pickup_date.strftime('%m/%d/%Y'),
              Origin: serialize_location(shipment.origin),
              Destinations: [
                serialize_location(shipment.destination)
              ]
            }.compact
          end

          private

          # @param [Physical::Location] location
          # @return [Hash]
          def serialize_location(location)
            {
              City: location.city,
              StateOrProvince: location.region.code,
              ZipOrPostalCode: location.zip,
              CountryCode: location.country.alpha_3_code
            }.compact
          end
        end
      end
    end
  end
end
