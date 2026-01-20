# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::G2Mint::REST::GenerateRatesRequestHash do
  describe ".call" do
    subject(:call) { described_class.call(shipment: shipment, options: options) }

    let(:origin) do
      FactoryBot.build(
        :physical_location,
        company_name: "Origin Co",
        address1: "123 Maple St",
        city: "New York",
        region: "NY",
        zip: "10001",
        country: "US"
      )
    end

    let(:destination) do
      FactoryBot.build(
        :physical_location,
        company_name: "Destination Co",
        address1: "456 Oak St",
        city: "Los Angeles",
        region: "CA",
        zip: "90001",
        country: "US"
      )
    end

    let(:bill_to_location) do
      FactoryBot.build(
        :physical_location,
        company_name: "Bill To Co",
        address1: "789 Pine St",
        city: "Chicago",
        region: "IL",
        zip: "60601",
        country: "US"
      )
    end

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
        request_id: "test-request-123",
        account_id: "account-456",
        owner_tenant: "tenant-789",
        bill_to_location: bill_to_location,
        bill_to_location_name: "Test Billing Location",
        bill_to_contact: {
          firstName: "John",
          lastName: "Doe",
          phoneNumber: "555-1234",
          email: "john@example.com"
        },
        direction: "OUTBOUND",
        freight_terms: "THIRD_PARTY",
        accessorials: ["LIFO"],
        transportation_modes: ["LTL"],
        pickup_date: Date.parse("2026-01-15")
      )
    end

    it "has the correct top-level structure" do
      expect(call[:requestId]).to eq("test-request-123")
      expect(call[:isSync]).to be(true)
      expect(call[:consolidateSaving]).to be(false)
      expect(call[:requestIdType]).to eq("SHIPMENT")
      expect(call[:direction]).to eq("OUTBOUND")
      expect(call[:freightTerms]).to eq("THIRD_PARTY")
      expect(call[:accountID]).to eq("account-456")
      expect(call[:ownerTenant]).to eq("tenant-789")
      expect(call[:accessorials]).to eq(["LIFO"])
      expect(call[:transportationModes]).to eq(["LTL"])
    end

    it "has the correct UOM" do
      expect(call[:uom]).to eq({ length: "IN", weight: "LB" })
    end

    it "has two stops" do
      expect(call[:stops].length).to eq(2)
    end

    describe "pickup stop" do
      subject(:pickup_stop) { call[:stops].first }

      it "has the correct type" do
        expect(pickup_stop[:type]).to eq("PICKUP")
        expect(pickup_stop[:sequence]).to eq(1)
      end

      it "has the correct address" do
        expect(pickup_stop[:address][:city]).to eq("New York")
        expect(pickup_stop[:address][:stateProvince]).to eq("NY")
        expect(pickup_stop[:address][:postalCode]).to eq("10001")
      end

      it "has the expected date" do
        expect(pickup_stop[:expectedStart][:date]).to eq("2026-01-15T00:00:00.000Z")
      end
    end

    describe "delivery stop" do
      subject(:delivery_stop) { call[:stops].second }

      it "has the correct type" do
        expect(delivery_stop[:type]).to eq("DELIVERY")
        expect(delivery_stop[:sequence]).to eq(2)
      end

      it "has the correct address" do
        expect(delivery_stop[:address][:city]).to eq("Los Angeles")
        expect(delivery_stop[:address][:stateProvince]).to eq("CA")
        expect(delivery_stop[:address][:postalCode]).to eq("90001")
      end
    end

    describe "bill to" do
      subject(:bill_to) { call[:billTo] }

      it "has the correct location" do
        expect(bill_to[:location][:name]).to eq("Test Billing Location")
      end

      it "has the correct address" do
        expect(bill_to[:address][:city]).to eq("Chicago")
        expect(bill_to[:address][:stateProvince]).to eq("IL")
      end

      it "has the correct contact" do
        expect(bill_to[:contact][:firstName]).to eq("John")
        expect(bill_to[:contact][:lastName]).to eq("Doe")
      end
    end

    it "has handling units with structure ID" do
      expect(call[:handlingUnits].length).to eq(1)
      expect(call[:handlingUnits].first[:id]).to eq("structure-1")
      expect(call[:handlingUnits].first[:weight]).to eq(500)
    end

    it "has packaging units with package ID" do
      expect(call[:packagingUnits].length).to eq(1)
      expect(call[:packagingUnits].first[:id]).to eq("pkg-1")
    end

    it "has commodities with structure ID as handling unit ID" do
      expect(call[:commodities].length).to eq(1)
      expect(call[:commodities].first[:handlingUnitId]).to eq("structure-1")
      expect(call[:commodities].first[:freightClass]).to eq("50")
    end
  end
end
