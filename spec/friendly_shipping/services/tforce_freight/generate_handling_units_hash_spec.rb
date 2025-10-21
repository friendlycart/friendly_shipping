# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::GenerateHandlingUnitsHash do
  subject { described_class.call(shipment: shipment, options: options) }

  let(:shipment) { Physical::Shipment.new(structures: pallets) }
  let(:pallets) { [pallet_1, pallet_2, other] }

  let(:pallet_1) do
    Physical::Structure.new(
      id: "pallet 1",
      dimensions: [
        Measured::Length(48, :in),
        Measured::Length(40, :in),
        Measured::Length(54, :in)
      ]
    )
  end

  let(:pallet_2) do
    # Intentionally leaving dimensions blank
    Physical::Structure.new(id: "pallet 2")
  end

  let(:other) do
    Physical::Structure.new(
      id: "other",
      dimensions: [
        Measured::Length(50, :in),
        Measured::Length(45, :in),
        Measured::Length(37, :in)
      ]
    )
  end

  let(:options) do
    FriendlyShipping::Services::TForceFreight::RatesOptions.new(
      billing_address: billing_address,
      shipping_method: shipping_method,
      structure_options: [
        FriendlyShipping::Services::TForceFreight::StructureOptions.new(
          structure_id: "pallet 1",
          handling_unit: :pallet
        ),
        FriendlyShipping::Services::TForceFreight::StructureOptions.new(
          structure_id: "pallet 2",
          handling_unit: :pallet
        ),
        FriendlyShipping::Services::TForceFreight::StructureOptions.new(
          structure_id: "other",
          handling_unit: :other
        )
      ]
    )
  end

  let(:billing_address) { FactoryBot.build(:physical_location) }
  let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: "03") }

  it do
    is_expected.to eq(
      handlingUnitOne: {
        quantity: 2,
        typeCode: "PLT"
      },
      handlingUnitTwo: {
        quantity: 1,
        typeCode: "OTH"
      },
      handlingUnits: [
        {
          pieces: 1,
          packagingType: "PLT",
          dangerousGoods: false,
          dimensions: {
            length: 48,
            width: 40,
            height: 54,
            unit: "IN"
          }
        },
        {
          pieces: 1,
          packagingType: "OTH",
          dangerousGoods: false,
          dimensions: {
            length: 50,
            width: 45,
            height: 37,
            unit: "IN"
          }
        }
      ]
    )
  end

  describe "deprecated packages behavior" do
    # TODO: Remove when deprecated packages are removed

    let(:shipment) { Physical::Shipment.new(packages: packages) }
    let(:packages) { [pallet_1, pallet_2, other] }

    let(:pallet_1) { Physical::Package.new(id: "pallet 1") }
    let(:pallet_2) { Physical::Package.new(id: "pallet 2") }
    let(:other) { Physical::Package.new(id: "other") }

    let(:options) do
      FriendlyShipping::Services::TForceFreight::RatesOptions.new(
        billing_address: billing_address,
        shipping_method: shipping_method,
        package_options: [
          FriendlyShipping::Services::TForceFreight::PackageOptions.new(
            package_id: "pallet 1",
            handling_unit: :pallet
          ),
          FriendlyShipping::Services::TForceFreight::PackageOptions.new(
            package_id: "pallet 2",
            handling_unit: :pallet
          ),
          FriendlyShipping::Services::TForceFreight::PackageOptions.new(
            package_id: "other",
            handling_unit: :other
          )
        ]
      )
    end

    let(:billing_address) { FactoryBot.build(:physical_location) }
    let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: "03") }

    it do
      is_expected.to eq(
        handlingUnitOne: {
          quantity: 2,
          typeCode: "PLT"
        },
        handlingUnitTwo: {
          quantity: 1,
          typeCode: "OTH"
        }
      )
    end
  end
end
