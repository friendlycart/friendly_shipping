# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::G2Mint::REST::StructureOptions do
  subject(:structure_options) { described_class.new(structure_id: "structure-1") }

  it { is_expected.to be_a(FriendlyShipping::StructureOptions) }
  it { is_expected.to respond_to(:handling_unit_type) }
  it { is_expected.to respond_to(:handling_unit_config_code) }

  describe "default values" do
    it "defaults to PALLET handling unit type" do
      expect(structure_options.handling_unit_type).to eq("PALLET")
    end

    it "defaults to nil handling_unit_config_code" do
      expect(structure_options.handling_unit_config_code).to be_nil
    end
  end

  describe "custom values" do
    subject(:structure_options) do
      described_class.new(
        structure_id: "structure-1",
        handling_unit: :crate,
        handling_unit_config_code: "CONFIG-123"
      )
    end

    it "has the custom handling unit type" do
      expect(structure_options.handling_unit_type).to eq("CRATE")
    end

    it "has the custom handling_unit_config_code" do
      expect(structure_options.handling_unit_config_code).to eq("CONFIG-123")
    end
  end

  describe "handling unit types" do
    FriendlyShipping::Services::G2Mint::REST::StructureOptions::HANDLING_UNIT_TYPES.each do |key, value|
      context "with handling_unit: :#{key}" do
        subject(:structure_options) { described_class.new(structure_id: "test", handling_unit: key) }

        it "returns #{value} as the handling unit type" do
          expect(structure_options.handling_unit_type).to eq(value)
        end
      end
    end
  end

  describe "#options_for_package" do
    let(:package) { Physical::Package.new(id: "pkg-1") }

    context "with matching package options" do
      let(:package_options) do
        FriendlyShipping::Services::G2Mint::REST::PackageOptions.new(
          package_id: "pkg-1",
          freight_class: "250"
        )
      end

      subject(:structure_options) do
        described_class.new(
          structure_id: "structure-1",
          package_options: [package_options]
        )
      end

      it "returns the matching package options" do
        expect(structure_options.options_for_package(package)).to eq(package_options)
      end
    end

    context "without matching package options" do
      it "returns default package options" do
        result = structure_options.options_for_package(package)
        expect(result).to be_a(FriendlyShipping::Services::G2Mint::REST::PackageOptions)
        expect(result.freight_class).to eq("50")
      end
    end
  end
end
