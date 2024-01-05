# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      class GenerateCommodityInformation
        # @param [Physical::Shipment] shipment
        # @param [FriendlyShipping::Services::TForceFreight::RatesOptions] options
        def self.call(shipment:, options:)
          shipment.packages.flat_map do |package|
            package_options = options.options_for_package(package)
            package.items.map do |item|
              item_options = package_options.options_for_item(item)
              {
                class: item_options.freight_class,
                nmfc: {
                  prime: item_options.nmfc_primary_code,
                  sub: item_options.nmfc_sub_code
                },
                pieces: 1, # We don't support grouping yet
                weight: {
                  weight: item.weight.convert_to(:pounds).value.to_f.round(2),
                  weightUnit: "LBS"
                },
                packagingType: item_options.packaging_code,
                dangerousGoods: false,
                dimensions: {
                  length: item.length.convert_to(:inches).value.to_f.round(2),
                  width: item.width.convert_to(:inches).value.to_f.round(2),
                  height: item.height.convert_to(:inches).value.to_f.round(2),
                  unit: "IN"
                }
              }
            end
          end
        end
      end
    end
  end
end
