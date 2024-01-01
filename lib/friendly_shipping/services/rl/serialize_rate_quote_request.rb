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
                Items: options.packages_serializer.call(packages: shipment.packages, options: options),
                DeclaredValue: options.declared_value,
                AdditionalServices: options.additional_service_codes,
                Pallets: serialize_pallets(shipment.pallets)
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

          # @param packages [Array<Physical::Package>] the items (as packages) to serialize
          # @param options [RateQuoteOptions] options for the items
          # @return [Array<Hash>] the serialized items
          def serialize_items(packages, options)
            item_hashes = packages.flat_map do |package|
              package_options = options.options_for_package(package)
              package.items.map do |item|
                item_options = package_options.options_for_item(item)
                {
                  Class: item_options.freight_class,
                  Weight: item.weight.convert_to(:pounds)
                }
              end
            end
            group_items(item_hashes)
          end

          # @param pallets [Array<Physical::Pallet>] the pallets to serialize
          # @return [Array<Hash>] the serialized pallets
          def serialize_pallets(pallets)
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
