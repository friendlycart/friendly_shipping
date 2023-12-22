# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::RateQuoteOptions do
  subject(:options) do
    described_class.new(
      pickup_date: Time.now,
      additional_service_codes: additional_service_codes
    )
  end

  let(:additional_service_codes) { %w[Hazmat] }

  [
    :pickup_date,
    :declared_value,
    :additional_service_codes,
    :packages_serializer
  ].each do |attr|
    it { is_expected.to respond_to(attr) }
  end

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::Services::RL::PackageOptions }
    let(:required_attrs) { { pickup_date: Time.now } }
  end

  describe "#packages_serializer" do
    subject { options.packages_serializer }

    it { is_expected.to eq(FriendlyShipping::Services::RL::RateQuotePackagesSerializer) }
  end

  describe "validate additional service codes" do
    context "with invalid additional service code" do
      let(:additional_service_codes) { %w[InsidePickup bogus] }

      it "raises exception" do
        expect { options }.to raise_exception(ArgumentError, "Invalid additional service code(s): bogus")
      end
    end
  end
end
