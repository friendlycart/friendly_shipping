# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngineLTL::SerializePackages do
  subject { described_class.call(packages: packages, options: options) }

  let(:packages) { [pallet_1, pallet_2] }

  let(:options) do
    FriendlyShipping::Services::ShipEngineLTL::QuoteOptions.new(
      service_code: "stnd",
      pickup_date: Time.parse("2023-07-19 10:30:00 UTC"),
      accessorial_service_codes: %w[LFTP IPU],
      package_options: [
        FriendlyShipping::Services::ShipEngineLTL::PackageOptions.new(
          package_id: "pallet 1",
          item_options: [
            FriendlyShipping::Services::ShipEngineLTL::ItemOptions.new(
              item_id: "item 1",
              packaging_code: "box",
              freight_class: "92.5",
              nmfc_code: "16030 sub 1"
            )
          ]
        ),
        FriendlyShipping::Services::ShipEngineLTL::PackageOptions.new(
          package_id: "pallet 2",
          item_options: [
            FriendlyShipping::Services::ShipEngineLTL::ItemOptions.new(
              item_id: "item 2",
              packaging_code: "box",
              freight_class: "92.5",
              nmfc_code: "16030 sub 1"
            )
          ]
        )
      ]
    )
  end

  let(:pallet_1) do
    FactoryBot.build(
      :physical_package,
      id: "pallet 1",
      items: [item_1],
      container: container
    )
  end

  let(:pallet_2) do
    FactoryBot.build(
      :physical_package,
      id: "pallet 2",
      items: [item_2],
      container: container
    )
  end

  let(:container) do
    FactoryBot.build(:physical_pallet)
  end

  let(:item_1) do
    FactoryBot.build(
      :physical_item,
      id: "item 1",
      description: "Tumblers",
      weight: Measured::Weight(10.53, :lb),
      dimensions: [
        Measured::Length(7.874, :in),
        Measured::Length(5.906, :in),
        Measured::Length(11.811, :in)
      ]
    )
  end

  let(:item_2) do
    FactoryBot.build(
      :physical_item,
      id: "item 2",
      description: "Wicks",
      weight: Measured::Weight(1.06, :lb),
      dimensions: [
        Measured::Length(4.341, :in),
        Measured::Length(2.354, :in),
        Measured::Length(1.902, :in)
      ]
    )
  end

  it do
    is_expected.to eq(
      [
        {
          code: "box",
          description: "Tumblers",
          freight_class: "92.5",
          nmfc_code: "16030 sub 1",
          weight: {
            unit: "pounds",
            value: 11
          },
          dimensions: {
            length: 8,
            width: 6,
            height: 12,
            unit: "inches"
          },
          quantity: 1,
          stackable: true,
          hazardous_materials: false
        },
        {
          code: "box",
          description: "Wicks",
          freight_class: "92.5",
          nmfc_code: "16030 sub 1",
          weight: {
            unit: "pounds",
            value: 2
          },
          dimensions: {
            length: 5,
            width: 3,
            height: 2,
            unit: "inches"
          },
          quantity: 1,
          stackable: true,
          hazardous_materials: false
        }
      ]
    )
  end
end
