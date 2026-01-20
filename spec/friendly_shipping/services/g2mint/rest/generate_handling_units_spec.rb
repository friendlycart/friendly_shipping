# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::G2Mint::REST::GenerateHandlingUnits do
  describe ".call" do
    subject(:call) { described_class.call(shipment: shipment, options: options) }

    let(:origin) { FactoryBot.build(:physical_location) }
    let(:destination) { FactoryBot.build(:physical_location) }

    let(:package) do
      Physical::Package.new(
        id: "pkg-1",
        weight: Measured::Weight(500, :lb)
      )
    end

    let(:structure) do
      Physical::Structure.new(
        id: "structure-1",
        packages: [package],
        dimensions: [
          Measured::Length(48, :in),
          Measured::Length(40, :in),
          Measured::Length(48, :in)
        ]
      )
    end

    let(:shipment) do
      Physical::Shipment.new(
        origin: origin,
        destination: destination,
        structures: [structure]
      )
    end

    let(:options) do
      FriendlyShipping::Services::G2Mint::REST::RatesOptions.new(
        account_id: "test-account",
        owner_tenant: "test-tenant",
        bill_to_location: origin,
        bill_to_contact: { firstName: "John", lastName: "Doe" }
      )
    end

    it "returns handling units array" do
      expect(call).to be_an(Array)
      expect(call.length).to eq(1)
    end

    it "has the correct structure" do
      handling_unit = call.first
      expect(handling_unit[:id]).to eq("structure-1")
      expect(handling_unit[:units]).to eq(1)
      expect(handling_unit[:unitType]).to eq("PALLET")
      expect(handling_unit[:weight]).to eq(500)
      expect(handling_unit[:length]).to eq(48)
      expect(handling_unit[:width]).to eq(40)
      expect(handling_unit[:height]).to eq(48)
    end

    context "with multiple packages in a structure" do
      let(:package2) do
        Physical::Package.new(
          id: "pkg-2",
          weight: Measured::Weight(300, :lb)
        )
      end

      let(:structure) do
        Physical::Structure.new(
          id: "structure-1",
          packages: [package, package2],
          dimensions: [
            Measured::Length(48, :in),
            Measured::Length(40, :in),
            Measured::Length(48, :in)
          ]
        )
      end

      it "sums the weight of all packages" do
        handling_unit = call.first
        expect(handling_unit[:weight]).to eq(800)
      end
    end

    context "with multiple structures" do
      let(:structure2) do
        Physical::Structure.new(
          id: "structure-2",
          packages: [Physical::Package.new(id: "pkg-2", weight: Measured::Weight(300, :lb))],
          dimensions: [
            Measured::Length(40, :in),
            Measured::Length(40, :in),
            Measured::Length(40, :in)
          ]
        )
      end

      let(:shipment) do
        Physical::Shipment.new(
          origin: origin,
          destination: destination,
          structures: [structure, structure2]
        )
      end

      it "returns handling unit for each structure" do
        expect(call.length).to eq(2)
        expect(call.first[:id]).to eq("structure-1")
        expect(call.second[:id]).to eq("structure-2")
      end
    end

    context "with custom handling unit type" do
      let(:options) do
        FriendlyShipping::Services::G2Mint::REST::RatesOptions.new(
          account_id: "test-account",
          owner_tenant: "test-tenant",
          bill_to_location: origin,
          bill_to_contact: { firstName: "John", lastName: "Doe" },
          structure_options: [
            FriendlyShipping::Services::G2Mint::REST::StructureOptions.new(
              structure_id: "structure-1",
              handling_unit: :crate
            )
          ]
        )
      end

      it "uses the custom handling unit type" do
        expect(call.first[:unitType]).to eq("CRATE")
      end
    end
  end
end
