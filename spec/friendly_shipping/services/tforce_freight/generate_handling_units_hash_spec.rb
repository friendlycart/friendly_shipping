# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::GenerateHandlingUnitsHash do
  subject { described_class.call(shipment: shipment, options: options) }

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
        FriendlyShipping::Services::TForceFreight::RatesPackageOptions.new(
          package_id: "pallet 1",
          handling_unit: :pallet
        ),
        FriendlyShipping::Services::TForceFreight::RatesPackageOptions.new(
          package_id: "pallet 2",
          handling_unit: :pallet
        ),
        FriendlyShipping::Services::TForceFreight::RatesPackageOptions.new(
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
