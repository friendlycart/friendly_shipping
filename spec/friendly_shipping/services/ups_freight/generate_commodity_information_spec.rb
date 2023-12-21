# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::GenerateCommodityInformation do
  describe ".call" do
    subject(:call) { described_class.call(shipment: shipment, options: options) }

    let(:shipment) { Physical::Shipment.new(packages: packages) }
    let(:packages) { [pallet_1, pallet_2] }

    let(:pallet_1) do
      Physical::Package.new(
        id: "pallet 1",
        items: [item_1]
      )
    end

    let(:pallet_2) do
      Physical::Package.new(
        id: "pallet 2",
        items: [item_2]
      )
    end

    let(:item_1) do
      Physical::Item.new(
        id: "package 1",
        weight: Measured::Weight(10.523, :lbs),
        dimensions: [
          Measured::Length(1.874, :in),
          Measured::Length(3.906, :in),
          Measured::Length(5.811, :in)
        ]
      )
    end

    let(:item_2) do
      Physical::Item.new(
        id: "package 2",
        weight: Measured::Weight(8.243, :lbs),
        dimensions: [
          Measured::Length(1.341, :in),
          Measured::Length(3.294, :in),
          Measured::Length(5.912, :in)
        ]
      )
    end

    let(:options) do
      FriendlyShipping::Services::UpsFreight::RatesOptions.new(
        shipper_number: "123",
        billing_address: billing_address,
        shipping_method: shipping_method,
        package_options: shipment.packages.map do |package|
          FriendlyShipping::Services::UpsFreight::RatesPackageOptions.new(
            package_id: package.id,
            item_options: package.items.map do |item|
              FriendlyShipping::Services::UpsFreight::RatesItemOptions.new(
                item_id: item.id,
                packaging: :box,
                freight_class: "92.5"
              )
            end
          )
        end
      )
    end

    let(:billing_address) { FactoryBot.build(:physical_location) }
    let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: "03") }

    it do
      is_expected.to eq(
        [
          {
            Description: "Commodities",
            FreightClass: "92.5",
            NumberOfPieces: "1",
            PackagingType: { Code: "BOX" },
            Weight: {
              UnitOfMeasurement: { Code: "LBS" },
              Value: "10.52"
            }
          },
          {
            Description: "Commodities",
            FreightClass: "92.5",
            NumberOfPieces: "1",
            PackagingType: { Code: "BOX" },
            Weight: {
              UnitOfMeasurement: { Code: "LBS" },
              Value: "8.24"
            }
          }
        ]
      )
    end
  end
end
