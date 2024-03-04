# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::SerializeAddressResidentialIndicator do
  subject(:call) { described_class.call(location) }

  let(:location) { Physical::Location.new(address_type: address_type) }
  let(:address_type) { "residential" }

  it { is_expected.to eq(address_residential_indicator: "yes") }

  context "with commercial address type" do
    let(:address_type) { "commercial" }

    it { is_expected.to eq(address_residential_indicator: "no") }
  end

  context "with missing address type" do
    let(:address_type) { nil }

    it { is_expected.to eq(address_residential_indicator: "unknown") }
  end
end
