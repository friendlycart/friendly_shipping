# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::GenerateHandlingUnitsHash do
  subject { described_class.call(shipment: shipment, options: options) }

  let(:shipment) { Physical::Shipment.new(structures: pallets) }
  let(:pallets) { [pallet_1, pallet_2, other] }

  let(:pallet_1) { Physical::Structure.new(id: "pallet 1") }
  let(:pallet_2) { Physical::Structure.new(id: "pallet 2") }
  let(:other) { Physical::Structure.new(id: "other") }

  let(:options) do
    FriendlyShipping::Services::UpsFreight::RatesOptions.new(
      shipper_number: "123",
      billing_address: billing_address,
      shipping_method: shipping_method,
      structure_options: [
        FriendlyShipping::Services::UpsFreight::RatesStructureOptions.new(
          structure_id: "pallet 1",
          handling_unit: :pallet
        ),
        FriendlyShipping::Services::UpsFreight::RatesStructureOptions.new(
          structure_id: "pallet 2",
          handling_unit: :pallet
        ),
        FriendlyShipping::Services::UpsFreight::RatesStructureOptions.new(
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
      {
        HandlingUnitOne: {
          Quantity: "2",
          Type: {
            Code: "PLT",
            Description: "Pallet"
          }
        },
        HandlingUnitTwo: {
          Quantity: "1",
          Type: {
            Code: "OTH",
            Description: "Other"
          }
        }
      }
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
      FriendlyShipping::Services::UpsFreight::RatesOptions.new(
        shipper_number: "123",
        billing_address: billing_address,
        shipping_method: shipping_method,
        package_options: [
          FriendlyShipping::Services::UpsFreight::RatesPackageOptions.new(
            package_id: "pallet 1",
            handling_unit: :pallet
          ),
          FriendlyShipping::Services::UpsFreight::RatesPackageOptions.new(
            package_id: "pallet 2",
            handling_unit: :pallet
          ),
          FriendlyShipping::Services::UpsFreight::RatesPackageOptions.new(
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
        {
          HandlingUnitOne: {
            Quantity: "2",
            Type: {
              Code: "PLT",
              Description: "Pallet"
            }
          },
          HandlingUnitTwo: {
            Quantity: "1",
            Type: {
              Code: "OTH",
              Description: "Other"
            }
          }
        }
      )
    end
  end
end
