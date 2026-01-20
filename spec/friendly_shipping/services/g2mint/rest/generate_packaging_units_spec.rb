# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::G2Mint::REST::GeneratePackagingUnits do
  describe ".call" do
    subject(:call) { described_class.call(shipment: shipment, options: options) }

    let(:origin) { FactoryBot.build(:physical_location) }
    let(:destination) { FactoryBot.build(:physical_location) }

    let(:package) do
      Physical::Package.new(
        id: "pkg-1",
        weight: Measured::Weight(500, :lb),
        dimensions: [
          Measured::Length(24, :in),
          Measured::Length(18, :in),
          Measured::Length(12, :in)
        ]
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

    it "returns packaging units array" do
      expect(call).to be_an(Array)
      expect(call.length).to eq(1)
    end

    it "has the correct structure" do
      packaging_unit = call.first
      expect(packaging_unit[:id]).to eq("pkg-1")
      expect(packaging_unit[:quantity]).to eq(1)
      expect(packaging_unit[:weight]).to eq(500)
      expect(packaging_unit[:length]).to eq(24)
      expect(packaging_unit[:width]).to eq(18)
      expect(packaging_unit[:height]).to eq(12)
    end

    context "with multiple packages in a structure" do
      let(:package2) do
        Physical::Package.new(
          id: "pkg-2",
          weight: Measured::Weight(300, :lb),
          dimensions: [
            Measured::Length(20, :in),
            Measured::Length(16, :in),
            Measured::Length(10, :in)
          ]
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

      it "returns a packaging unit for each package" do
        expect(call.length).to eq(2)
        expect(call.first[:id]).to eq("pkg-1")
        expect(call.first[:weight]).to eq(500)
        expect(call.second[:id]).to eq("pkg-2")
        expect(call.second[:weight]).to eq(300)
      end
    end

    context "with multiple structures" do
      let(:package2) do
        Physical::Package.new(
          id: "pkg-2",
          weight: Measured::Weight(300, :lb),
          dimensions: [
            Measured::Length(20, :in),
            Measured::Length(16, :in),
            Measured::Length(10, :in)
          ]
        )
      end

      let(:structure2) do
        Physical::Structure.new(
          id: "structure-2",
          packages: [package2],
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

      it "returns packaging units for packages across all structures" do
        expect(call.length).to eq(2)
        expect(call.first[:id]).to eq("pkg-1")
        expect(call.second[:id]).to eq("pkg-2")
      end
    end
  end
end
