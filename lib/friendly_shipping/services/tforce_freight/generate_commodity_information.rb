# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Generates a commodity information hash for JSON serialization.
      class GenerateCommodityInformation
        # @param shipment [Physical::Shipment] the shipment with commodities to serialize
        # @param options [RatesOptions] the options to serialize
        # @return [Array<Hash>] commodities hash suitable for JSON request
        def self.call(shipment:, options:)
          shipment.packages.flat_map do |package|
            package_options = options.options_for_package(package)
            package.items.map do |item|
              item_options = package_options.options_for_item(item)
              {
                description: item.description.presence || "Commodities",
                class: item_options.freight_class,
                nmfc: {
                  prime: item_options.nmfc_primary_code,
                  sub: item_options.nmfc_sub_code
                }.compact.presence,
                pieces: 1, # We don't support grouping yet
                weight: {
                  weight: item.weight.convert_to(:pounds).value.to_f.round(2),
                  weightUnit: "LBS"
                },
                packagingType: item_options.packaging_code,
                dangerousGoods: item_options.hazardous,
                dimensions: {
                  length: item.length.convert_to(:inches).value.to_f.round(2),
                  width: item.width.convert_to(:inches).value.to_f.round(2),
                  height: item.height.convert_to(:inches).value.to_f.round(2),
                  unit: "IN"
                }
              }.compact
            end
          end
        end
      end
    end
  end
end
