# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::StructureOptions do
  subject(:options) { described_class.new(structure_id: "structure") }

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::Services::RL::PackageOptions }
    let(:required_attrs) { { structure_id: "structure" } }
  end

  describe "#handling_unit_code" do
    subject(:handling_unit_code) { options.handling_unit_code }

    it { is_expected.to eq("PLT") }

    context "with handling_unit: :skid" do
      let(:options) { described_class.new(structure_id: "structure", handling_unit: :skid) }

      it { is_expected.to eq("SKD") }
    end

    context "with handling_unit: :tote" do
      let(:options) { described_class.new(structure_id: "structure", handling_unit: :tote) }

      it { is_expected.to eq("TOTE") }
    end

    context "with an invalid handling unit" do
      it "raises KeyError" do
        expect do
          described_class.new(structure_id: "structure", handling_unit: :bogus)
        end.to raise_error(KeyError)
      end
    end
  end
end
