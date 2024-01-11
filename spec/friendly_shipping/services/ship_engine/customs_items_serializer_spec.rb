# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::CustomsItemsSerializer do
  subject { described_class.call([package], options) }

  let(:package) { FactoryBot.build(:physical_package, items: [item], void_fill_density: Measured::Density(0, :g_ml)) }
  let(:package_options) do
    [
      FriendlyShipping::Services::ShipEngine::LabelPackageOptions.new(
        package_id: package.id,
        package_code: :large_flat_rate_box,
        item_options: item_options
      )
    ]
  end
  let(:item) { FactoryBot.build(:physical_item, sku: "20010", description: "Wicks", cost: Money.new(120, "CAD")) }
  let(:item_options) do
    [
      FriendlyShipping::Services::ShipEngine::LabelItemOptions.new(
        item_id: item.id,
        commodity_code: "6116.10.0000",
        country_of_origin: "US"
      )
    ]
  end
  let(:options) do
    FriendlyShipping::Services::ShipEngine::LabelOptions.new(
      shipping_method: nil,
      label_format: :zpl,
      package_options: package_options
    )
  end

  it do
    is_expected.to match(
      [{
        sku: "20010",
        description: "Wicks",
        quantity: 1,
        value: {
          amount: 1.20,
          currency: "CAD"
        },
        harmonized_tariff_code: "6116.10.0000",
        country_of_origin: "US"
      }]
    )
  end
end
