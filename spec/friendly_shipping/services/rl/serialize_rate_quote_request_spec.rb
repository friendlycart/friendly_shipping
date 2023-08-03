# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::SerializeRateQuoteRequest do
  subject { described_class.call(shipment: shipment, options: options) }

  let(:shipment) do
    FactoryBot.build(
      :physical_shipment,
      origin: origin,
      destination: destination,
      pallets: [pallet_1, pallet_2],
      packages: [package_1, package_2]
    )
  end

  let(:options) do
    FriendlyShipping::Services::RL::RateQuoteOptions.new(
      pickup_date: Time.parse("2023-07-19 10:30:00 UTC"),
      declared_value: 124.35,
      additional_service_codes: %w[DestinationLiftgate LimitedAccessDelivery],
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

  let(:pallet_1) do
    FactoryBot.build(
      :physical_pallet,
      id: "pallet 1"
    )
  end

  let(:pallet_2) do
    FactoryBot.build(
      :physical_pallet,
      id: "pallet 1"
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

  let(:origin) do
    FactoryBot.build(
      :physical_location,
      address1: "123 Maple St",
      city: "New York",
      region: "NY",
      zip: "10001"
    )
  end

  let(:destination) do
    FactoryBot.build(
      :physical_location,
      address1: "456 Oak St",
      city: "Boulder",
      region: "CO",
      zip: "80301"
    )
  end

  it do
    is_expected.to eq(
      {
        RateQuote: {
          PickupDate: "07/19/2023",
          Origin: {
            City: "New York",
            StateOrProvince: "NY",
            ZipOrPostalCode: "10001",
            CountryCode: "USA"
          },
          Destination: {
            City: "Boulder",
            StateOrProvince: "CO",
            ZipOrPostalCode: "80301",
            CountryCode: "USA"
          },
          Items: [{
            Class: "92.5",
            Weight: 12,
            Quantity: 2
          }],
          DeclaredValue: 124.35,
          AdditionalServices: %w[
            DestinationLiftgate
            LimitedAccessDelivery
          ],
          Pallets: [{
            Code: "0001",
            Weight: 49,
            Quantity: 2
          }]
        }
      }
    )
  end
end
