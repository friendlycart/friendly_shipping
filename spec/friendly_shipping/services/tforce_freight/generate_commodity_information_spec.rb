# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::GenerateCommodityInformation do
  describe ".call" do
    subject(:call) { described_class.call(shipment: shipment, options: options) }

    let(:shipment) { Physical::Shipment.new(packages: packages) }
    let(:packages) { [package_one, package_two] }

    let(:package_one) do
      Physical::Package.new(
        id: "my_package_1",
        items: [item_one]
      )
    end

    let(:package_two) do
      Physical::Package.new(
        id: "my_package_2",
        items: [item_two]
      )
    end

    let(:item_one) do
      Physical::Item.new(
        id: "item_one",
        description: "Widgets",
        weight: Measured::Weight(10.523, :lbs),
        dimensions: [
          Measured::Length(1.874, :in),
          Measured::Length(3.906, :in),
          Measured::Length(5.811, :in)
        ]
      )
    end

    let(:item_two) do
      Physical::Item.new(
        id: "item_two",
        description: "Gadgets",
        weight: Measured::Weight(8.243, :lbs),
        dimensions: [
          Measured::Length(1.341, :in),
          Measured::Length(3.294, :in),
          Measured::Length(5.912, :in)
        ]
      )
    end

    let(:options) do
      FriendlyShipping::Services::TForceFreight::RatesOptions.new(
        pickup_date: pickup_date,
        billing_address: billing_address,
        shipping_method: shipping_method,
        package_options: shipment.packages.map do |package|
          FriendlyShipping::Services::TForceFreight::RatesPackageOptions.new(
            package_id: package.id,
            item_options: package.items.map do |item|
              FriendlyShipping::Services::TForceFreight::RatesItemOptions.new(
                item_id: item.id,
                packaging: :package,
                freight_class: "92.5",
                nmfc_primary_code: "87700",
                nmfc_sub_code: "07"
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
            description: "Widgets",
            class: "92.5",
            dangerousGoods: false,
            dimensions: {
              length: 1.87,
              width: 3.91,
              height: 5.81,
              unit: "IN"
            },
            nmfc: {
              prime: "87700",
              sub: "07"
            },
            packagingType: "PKG",
            pieces: 1,
            weight: {
              weight: 10.52,
              weightUnit: "LBS"
            }
          }, {
            description: "Gadgets",
            class: "92.5",
            dangerousGoods: false,
            dimensions: {
              length: 1.34,
              width: 3.29,
              height: 5.91,
              unit: "IN"
            },
            nmfc: {
              prime: "87700",
              sub: "07"
            },
            packagingType: "PKG",
            pieces: 1,
            weight: {
              weight: 8.24,
              weightUnit: "LBS"
            }
          }
        ]
      )
    end
  end
end
