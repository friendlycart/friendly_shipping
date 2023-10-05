# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::RateQuotePackagesSerializer do
  subject do
    described_class.call(
      packages: [package_1, package_2],
      options: options
    )
  end

  let(:options) do
    FriendlyShipping::Services::RL::RateQuoteOptions.new(
      pickup_date: Time.parse("2023-07-19 10:30:00 UTC"),
      package_options: [
        FriendlyShipping::Services::RL::PackageOptions.new(
          package_id: "package 1",
          item_options: [
            FriendlyShipping::Services::RL::ItemOptions.new(
              item_id: "item 1",
              freight_class: "92.5"
            )
          ]
        ),
        FriendlyShipping::Services::RL::PackageOptions.new(
          package_id: "package 2",
          item_options: [
            FriendlyShipping::Services::RL::ItemOptions.new(
              item_id: "item 2",
              freight_class: "92.5"
            )
          ]
        )
      ]
    )
  end

  let(:package_1) do
    FactoryBot.build(
      :physical_package,
      id: "package 1",
      items: [item_1],
      container: container
    )
  end

  let(:package_2) do
    FactoryBot.build(
      :physical_package,
      id: "package 2",
      items: [item_2],
      container: container
    )
  end

  let(:container) do
    FactoryBot.build(:physical_box)
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
      [{
        Class: "92.5",
        Height: 12,
        Length: 8,
        Weight: 12,
        Width: 6,
        Quantity: 2
      }]
    )
  end
end
