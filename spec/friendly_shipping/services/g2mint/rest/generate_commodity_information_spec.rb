# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::G2Mint::REST::GenerateCommodityInformation do
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
        bill_to_contact: { firstName: "John", lastName: "Doe" },
        structure_options: [
          FriendlyShipping::Services::G2Mint::REST::StructureOptions.new(
            structure_id: "structure-1",
            package_options: [
              FriendlyShipping::Services::G2Mint::REST::PackageOptions.new(
                package_id: "pkg-1",
                freight_class: "250",
                nmfc: "158880-03",
                is_hazmat: false,
                product_code: "3",
                packaging_unit: :box
              )
            ]
          )
        ]
      )
    end

    it "returns commodities array" do
      expect(call).to be_an(Array)
      expect(call.length).to eq(1)
    end

    it "has the correct structure" do
      commodity = call.first
      expect(commodity[:handlingUnitId]).to eq("structure-1")
      expect(commodity[:packageType]).to eq("BOX")
      expect(commodity[:packageUnitId]).to eq("pkg-1")
      expect(commodity[:freightClass]).to eq("250")
      expect(commodity[:nmfc]).to eq("158880-03")
      expect(commodity[:isHazmat]).to be(false)
      expect(commodity[:productCode]).to eq("3")
      expect(commodity[:weight]).to eq(500)
      expect(commodity[:units]).to eq(1)
    end

    context "with default package options" do
      let(:options) do
        FriendlyShipping::Services::G2Mint::REST::RatesOptions.new(
          account_id: "test-account",
          owner_tenant: "test-tenant",
          bill_to_location: origin,
          bill_to_contact: { firstName: "John", lastName: "Doe" }
        )
      end

      it "uses default freight class" do
        commodity = call.first
        expect(commodity[:freightClass]).to eq("50")
        expect(commodity[:isHazmat]).to be(false)
      end
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

      it "returns commodity for each package with same handling unit ID" do
        expect(call.length).to eq(2)
        expect(call.first[:handlingUnitId]).to eq("structure-1")
        expect(call.second[:handlingUnitId]).to eq("structure-1")
        expect(call.first[:weight]).to eq(500)
        expect(call.second[:weight]).to eq(300)
      end
    end

    context "with multiple structures" do
      let(:package2) do
        Physical::Package.new(
          id: "pkg-2",
          weight: Measured::Weight(300, :lb)
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

      it "returns commodities with correct handling unit IDs" do
        expect(call.length).to eq(2)
        expect(call.first[:handlingUnitId]).to eq("structure-1")
        expect(call.second[:handlingUnitId]).to eq("structure-2")
      end
    end
  end
end
