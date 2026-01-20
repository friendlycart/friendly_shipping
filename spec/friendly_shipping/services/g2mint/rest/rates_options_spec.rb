# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::G2Mint::REST::RatesOptions do
  subject(:options) do
    described_class.new(
      request_id: "test-request-id",
      account_id: "test-account-id",
      owner_tenant: "test-owner-tenant",
      bill_to_location: bill_to_location,
      bill_to_location_name: "Test Location",
      bill_to_location_id: "loc-123",
      bill_to_contact: bill_to_contact,
      distance: 500,
      direction: "OUTBOUND",
      freight_terms: "THIRD_PARTY",
      accessorials: ["LIFO"],
      transportation_modes: ["LTL"],
      pickup_date: Date.parse("2026-01-15"),
      pickup_time_window: { start: "08:00", end: "17:00" },
      pickup_contact: { firstName: "Pickup", lastName: "Person" },
      pickup_note: "Call before arrival",
      delivery_time_window: { start: "09:00", end: "18:00" },
      delivery_contact: { firstName: "Delivery", lastName: "Person" },
      delivery_note: "Leave at door"
    )
  end

  let(:bill_to_location) do
    Physical::Location.new(
      city: "Durham",
      zip: "27703",
      region: "NC",
      country: "US"
    )
  end

  let(:bill_to_contact) do
    {
      firstName: "John",
      lastName: "Doe",
      phoneNumber: "555-1234",
      email: "john@example.com"
    }
  end

  it { is_expected.to be_a(FriendlyShipping::ShipmentOptions) }

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::Services::G2Mint::REST::PackageOptions }
    let(:required_attrs) do
      {
        account_id: "test-account",
        owner_tenant: "test-tenant",
        bill_to_location: bill_to_location,
        bill_to_contact: bill_to_contact
      }
    end
  end

  it "has the right attributes" do
    expect(options.request_id).to eq("test-request-id")
    expect(options.account_id).to eq("test-account-id")
    expect(options.owner_tenant).to eq("test-owner-tenant")
    expect(options.bill_to_location).to eq(bill_to_location)
    expect(options.bill_to_location_name).to eq("Test Location")
    expect(options.bill_to_location_id).to eq("loc-123")
    expect(options.bill_to_contact).to eq(bill_to_contact)
    expect(options.distance).to eq(500)
    expect(options.direction).to eq("OUTBOUND")
    expect(options.freight_terms).to eq("THIRD_PARTY")
    expect(options.accessorials).to eq(["LIFO"])
    expect(options.transportation_modes).to eq(["LTL"])
    expect(options.pickup_date).to eq(Date.parse("2026-01-15"))
    expect(options.pickup_time_window).to eq({ start: "08:00", end: "17:00" })
    expect(options.pickup_contact).to eq({ firstName: "Pickup", lastName: "Person" })
    expect(options.pickup_note).to eq("Call before arrival")
    expect(options.delivery_time_window).to eq({ start: "09:00", end: "18:00" })
    expect(options.delivery_contact).to eq({ firstName: "Delivery", lastName: "Person" })
    expect(options.delivery_note).to eq("Leave at door")
  end

  it "has default generators" do
    expect(options.commodity_information_generator).to eq(
      FriendlyShipping::Services::G2Mint::REST::GenerateCommodityInformation
    )
    expect(options.handling_unit_generator).to eq(
      FriendlyShipping::Services::G2Mint::REST::GenerateHandlingUnits
    )
    expect(options.packaging_unit_generator).to eq(
      FriendlyShipping::Services::G2Mint::REST::GeneratePackagingUnits
    )
  end

  describe "default values" do
    subject(:options) do
      described_class.new(
        account_id: "test-account",
        owner_tenant: "test-tenant",
        bill_to_location: bill_to_location,
        bill_to_contact: bill_to_contact
      )
    end

    it "generates a UUID for request_id" do
      expect(options.request_id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it "defaults distance to nil" do
      expect(options.distance).to be_nil
    end

    it "defaults direction to OUTBOUND" do
      expect(options.direction).to eq("OUTBOUND")
    end

    it "defaults pickup_date to today" do
      expect(options.pickup_date).to eq(Date.today)
    end

    it "defaults accessorials to empty array" do
      expect(options.accessorials).to eq([])
    end

    it "defaults transportation_modes to empty array" do
      expect(options.transportation_modes).to eq([])
    end
  end

  describe "package options" do
    subject(:package_options) { options.options_for_package(package) }

    let(:package) { double(package_id: nil) }

    it { is_expected.to be_a(FriendlyShipping::Services::G2Mint::REST::PackageOptions) }
  end

  describe "structure options" do
    subject(:structure_options) { options.options_for_structure(structure) }

    let(:structure) { Physical::Structure.new(id: "structure-1") }

    context "with matching structure options" do
      subject(:options) do
        described_class.new(
          account_id: "test-account",
          owner_tenant: "test-tenant",
          bill_to_location: bill_to_location,
          bill_to_contact: bill_to_contact,
          structure_options: [
            FriendlyShipping::Services::G2Mint::REST::StructureOptions.new(
              structure_id: "structure-1",
              handling_unit: :crate
            )
          ]
        )
      end

      it "returns the matching structure options" do
        expect(structure_options.handling_unit_type).to eq("CRATE")
      end
    end

    context "without matching structure options" do
      subject(:options) do
        described_class.new(
          account_id: "test-account",
          owner_tenant: "test-tenant",
          bill_to_location: bill_to_location,
          bill_to_contact: bill_to_contact
        )
      end

      it "returns default structure options" do
        expect(structure_options).to be_a(FriendlyShipping::Services::G2Mint::REST::StructureOptions)
        expect(structure_options.handling_unit_type).to eq("PALLET")
      end
    end
  end
end
