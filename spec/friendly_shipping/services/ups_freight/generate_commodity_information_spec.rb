# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::GenerateCommodityInformation do
  describe ".call" do
    subject(:call) { described_class.call(shipment: shipment, options: options) }

    let(:shipment) { Physical::Shipment.new(structures: structures) }
    let(:structures) { [pallet_1, pallet_2] }

    let(:pallet_1) do
      Physical::Structure.new(
        id: "pallet 1",
        packages: [package_1]
      )
    end

    let(:pallet_2) do
      Physical::Structure.new(
        id: "pallet 2",
        packages: [package_2]
      )
    end

    let(:package_1) do
      Physical::Package.new(
        id: "package 1",
        items: [
          Physical::Item.new(
            weight: Measured::Weight(10.523, :lbs)
          )
        ],
        container: Physical::Box.new(
          dimensions: [
            Measured::Length(1.874, :in),
            Measured::Length(3.906, :in),
            Measured::Length(5.811, :in)
          ]
        )
      )
    end

    let(:package_2) do
      Physical::Package.new(
        id: "package 2",
        items: [
          Physical::Item.new(
            weight: Measured::Weight(8.243, :lbs)
          )
        ],
        container: Physical::Box.new(
          dimensions: [
            Measured::Length(1.341, :in),
            Measured::Length(3.294, :in),
            Measured::Length(5.912, :in)
          ]
        )
      )
    end

    let(:options) do
      FriendlyShipping::Services::UpsFreight::RatesOptions.new(
        shipper_number: "123",
        billing_address: billing_address,
        shipping_method: shipping_method,
        structure_options: shipment.structures.map do |structure|
          FriendlyShipping::Services::UpsFreight::RatesStructureOptions.new(
            structure_id: structure.id,
            package_options: structure.packages.map do |package|
              FriendlyShipping::Services::UpsFreight::RatesPackageOptions.new(
                package_id: package.id,
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

  describe "deprecated packages behavior" do
    # TODO: Remove when shipment.packages is no longer being used

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

      let(:pickup_date) { Date.today }

      let(:billing_address) do
        Physical::Location.new(
          city: "Durham",
          zip: "27703",
          region: "NC",
          country: "US"
        )
      end

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
end
