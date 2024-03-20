# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Serializes an R+L API request to get a shipping rate quote.
      class SerializeRateQuoteRequest
        class << self
          # @param shipment [Physical::Shipment] the shipment for the request
          # @param options [RateQuoteOptions] options for the request
          # @return [Hash] the serialized request
          def call(shipment:, options:)
            {
              RateQuote: {
                PickupDate: options.pickup_date.strftime('%m/%d/%Y'),
                Origin: serialize_location(shipment.origin),
                Destination: serialize_location(shipment.destination),
                Items: serialize_items(shipment, options),
                DeclaredValue: options.declared_value,
                AdditionalServices: options.additional_service_codes,
                Pallets: serialize_pallets(shipment)
              }.compact
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

          # @param shipment [Physical::Shipment]
          # @param options [RateQuoteOptions] options for the items
          # @return [Array<Hash>] the serialized items
          def serialize_items(shipment, options)
            if options.packages_serializer
              warn "[DEPRECATION] `packages_serializer` is deprecated.  Please use `structures_serializer` instead."
              options.packages_serializer.call(packages: shipment.packages, options: options)
            else
              options.structures_serializer.call(structures: shipment.structures, options: options)
            end
          end

          # @param shipment [Physical::Shipment]
          # @return [Array<Hash>] the serialized pallets
          def serialize_pallets(shipment)
            pallets = shipment.pallets.any? ? shipment.pallets : shipment.structures
            pallets.group_by do |pallet|
              pallet.weight.convert_to(:pounds).value.ceil
            end.map do |weight, grouped_pallets|
              {
                Code: "0001",
                Weight: weight,
                Quantity: grouped_pallets.size
              }
            end
          end
        end
      end
    end
  end
end
