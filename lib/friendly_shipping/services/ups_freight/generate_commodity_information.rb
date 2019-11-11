# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GenerateCommodityInformation
        def self.call(shipment:, options:)
          shipment.packages.flat_map do |package|
            package_options = options.options_for_package(package)
            package.items.map do |item|
              item_options = package_options.options_for_item(item)
              {
                # This is a required field
                Description: item.description || 'Commodities',
                Weight: {
                  UnitOfMeasurement: {
                    Code: 'LBS' # Only Pounds are supported
                  },
                  Value: item.weight.convert_to(:pounds).value.to_f.round(2).to_s
                },
                NumberOfPieces: '1', # We won't support this yet.
                PackagingType: {
                  Code: item_options.packaging_code
                },
                FreightClass: item_options.freight_class
              }
            end
          end
        end
      end
    end
  end
end
