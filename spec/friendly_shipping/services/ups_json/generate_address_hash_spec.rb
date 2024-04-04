# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::UpsJson::GenerateAddressHash do
  subject(:call) {
    described_class.call(
      location: location,
      international: international,
      shipper_number: shipper_number
    )
  }

  let(:location) do
    FactoryBot.build(:physical_location, company_name: "A very nice company", zip: "00001")
  end
  let(:international) { false }
  let(:shipper_number) { nil }

  it "returns a hash containing the name and address" do
    expect(subject[:Name]).to eq("A very nice company")
    expect(subject[:AttentionName]).to eq("Jane Doe")
    expect(subject[:Address][:AddressLine]).to eq(["11 Lovely Street", "Suite 100"])
    expect(subject[:Address][:City]).to eq("Herndon")
    expect(subject[:Address][:PostalCode]).to eq("00001")
    expect(subject[:Address][:StateProvinceCode]).to eq("VA")
    expect(subject[:Address][:CountryCode]).to eq("US")
    expect(subject[:Address][:ResidentialAddressIndicator]).to eq("X")
  end

  it "returns a compact hash" do
    expect(subject.values).not_to include(nil)
  end

  context "when the address is not a business address" do
    let(:location) { FactoryBot.build(:physical_location, company_name: nil, phone: "0998877665") }

    it "uses the recipient name for the AttentionName" do
      expect(subject[:Name]).to eq("Jane Doe")
      expect(subject[:AttentionName]).to be nil
      expect(subject[:Phone]).to eq({ Number: "0998877665" })
    end
  end

  context "when destination is international" do
    let(:international) { true }

    it "uses both Name and AttentionName" do
      expect(subject[:Name]).to eq("A very nice company")
      expect(subject[:AttentionName]).to eq("Jane Doe")
    end

    context "when the address is not a business address" do
      let(:location) { FactoryBot.build(:physical_location, company_name: nil, phone: "0998877665") }

      it "uses the recipient name for the AttentionName" do
        expect(subject[:Name]).to eq("Jane Doe")
        expect(subject[:AttentionName]).to eq("Jane Doe")
        expect(subject[:Phone]).to eq({ Number: "0998877665" })
      end
    end
  end

  context "with a very long name" do
    let(:location) do
      FactoryBot.build(:physical_location, company_name: "Stephanie's Specialty Soaps and More!", phone: "0998877665")
    end

    it "shortens it to the longest length allowed" do
      expect(subject[:Name]).to eq("Stephanie's Specialty Soaps and Mor")
    end
  end

  context "with a commercial address" do
    let(:location) { FactoryBot.build(:physical_location, address_type: "commercial") }

    it "does not include residential address indicator" do
      expect(subject[:Address].key?(:ResidentialAddressIndicator)).to be false
    end
  end

  context "with an unknown address" do
    let(:location) { FactoryBot.build(:physical_location, address_type: "unknown") }

    it "includes residential address indicator" do
      expect(subject[:Address][:ResidentialAddressIndicator]).to eq("X")
    end
  end

  context "with a shipper number" do
    let(:shipper_number) { "123456" }

    it "includes the shipper number" do
      expect(subject[:ShipperNumber]).to eq("123456")
    end
  end
end
