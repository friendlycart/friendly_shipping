# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngineLTL
      # Serializes packages for the rate quote API request.
      class SerializePackages
        class << self
          # @param packages [Array<Physical::Package>]
          # @param options [QuoteOptions]
          # @return [Array<Hash>]
          def call(packages:, options:)
            packages.flat_map do |package|
              package_options = options.options_for_package(package)
              package.items.map do |item|
                item_options = package_options.options_for_item(item)
                {
                  code: item_options.packaging_code,
                  freight_class: item_options.freight_class,
                  nmfc_code: item_options.nmfc_code,
                  description: item.description || "Commodities",
                  dimensions: {
                    width: item.width.convert_to(:inches).value.ceil,
                    height: item.height.convert_to(:inches).value.ceil,
                    length: item.length.convert_to(:inches).value.ceil,
                    unit: "inches"
                  },
                  weight: {
                    value: item.weight.convert_to(:pounds).value.ceil,
                    unit: "pounds"
                  },
                  quantity: 1, # we don't support this yet
                  stackable: item_options.stackable,
                  hazardous_materials: item_options.hazardous_materials
                }
              end
            end
          end
        end
      end
    end
  end
end
