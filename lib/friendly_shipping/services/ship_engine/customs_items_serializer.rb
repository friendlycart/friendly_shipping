# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      class CustomsItemsSerializer
        class << self
          def call(packages, options)
            packages.map do |package|
              package.items.group_by(&:sku).map do |sku, items|
                reference_item = items.first
                package_options = options.options_for_package(package)
                item_options = package_options.options_for_item(reference_item)
                {
                  sku: sku,
                  description: reference_item.description,
                  quantity: items.count,
                  value: {
                    amount: reference_item.cost.to_d,
                    currency: reference_item.cost.currency.to_s
                  },
                  harmonized_tariff_code: item_options.commodity_code,
                  country_of_origin: item_options.country_of_origin
                }
              end
            end.flatten
          end
        end
      end
    end
  end
end
