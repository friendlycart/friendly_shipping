# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::RatesPackageOptions do
  subject(:options) { described_class.new(package_id: "package") }

  [
    :packaging_code,
    :packaging_description,
    :freight_class,
    :nmfc_primary_code,
    :nmfc_sub_code,
    :hazardous
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  it "has the right attributes" do
    expect(subject.handling_unit_code).to eq("PLT")
    expect(subject.handling_unit_description).to eq("Pallet")
    expect(subject.handling_unit_tag).to eq("handlingUnitOne")
  end

  it_behaves_like "overrideable item options class" do
    let(:default_class) { FriendlyShipping::Services::TForceFreight::ItemOptions }
  end

  context "with loose packaging" do
    subject(:options) { described_class.new(package_id: "package", handling_unit: :loose) }

    it "has the right attributes" do
      expect(subject.handling_unit_code).to eq("LOO")
      expect(subject.handling_unit_description).to eq("Loose")
      expect(subject.handling_unit_tag).to eq("handlingUnitTwo")
    end
  end
end
