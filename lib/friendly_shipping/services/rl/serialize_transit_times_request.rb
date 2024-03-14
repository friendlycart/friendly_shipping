# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Serializes an R+L API request to get a shipment transit timing estimate.
      class SerializeTransitTimesRequest
        class << self
          # @param shipment [Physical::Shipment] the shipment for the request
          # @param options [RateQuoteOptions] options for the request
          # @return [Hash] the serialized request
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

          # @param location [Physical::Location] the location to serialize
          # @return [Hash] the serialized location
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
