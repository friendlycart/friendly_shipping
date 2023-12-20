# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::BOLOptions do
  subject(:options) do
    described_class.new(
      pickup_time_window: 1.hour.ago..1.hour.from_now,
      additional_service_codes: additional_service_codes
    )
  end

  let(:additional_service_codes) { %w[OriginLiftgate] }

  [
    :pickup_time_window,
    :pickup_instructions,
    :declared_value,
    :special_instructions,
    :reference_numbers,
    :additional_service_codes,
    :generate_universal_pro,
    :packages_serializer,
    :structures_serializer
  ].each do |attr|
    it { is_expected.to respond_to(attr) }
  end

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::Services::RL::PackageOptions }
    let(:required_attrs) { { pickup_time_window: 1.hour.ago..1.hour.from_now } }
  end

  it_behaves_like "overrideable structure options class" do
    let(:default_class) { FriendlyShipping::Services::RL::StructureOptions }
    let(:required_attrs) { { pickup_time_window: 1.hour.ago..1.hour.from_now } }
  end

  describe "package options class" do
    subject { options.send :package_options_class }

    it { is_expected.to eq(FriendlyShipping::Services::RL::PackageOptions) }

    context "when a custom class is passed" do
      let(:options) do
        described_class.new(
          pickup_time_window: 1.hour.ago..1.hour.from_now,
          package_options_class: Object
        )
      end

      it { is_expected.to eq(Object) }
    end
  end

  describe "#structures_serializer" do
    subject { options.structures_serializer }

    it { is_expected.to eq(FriendlyShipping::Services::RL::BOLStructuresSerializer) }
  end

  describe "#packages_serializer" do
    subject { options.packages_serializer }

    it { is_expected.to eq(FriendlyShipping::Services::RL::BOLPackagesSerializer) }
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
