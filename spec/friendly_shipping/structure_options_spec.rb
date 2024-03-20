# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::StructureOptions do
  subject(:options) { described_class.new(structure_id: "structure") }

  describe "#structure_id" do
    subject(:structure_id) { options.structure_id }
    it { is_expected.to eq("structure") }
  end

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::PackageOptions }
    let(:required_attrs) { { structure_id: "structure" } }
  end

  describe "#options_for_package" do
    subject(:options_for_package) { options.options_for_package(package) }

    let(:options) { described_class.new(structure_id: "structure", package_options: [package_options]) }
    let(:package_options) { FriendlyShipping::PackageOptions.new(package_id: "package") }
    let(:package) { double(id: "package") }

    it { is_expected.to eq(package_options) }

    context "when package options with matching package ID cannot be found" do
      let(:package) { double(id: "bogus") }

      it "returns default package options" do
        expect(options_for_package).to be_a(FriendlyShipping::PackageOptions)
        expect(options_for_package.package_id).to be_nil
      end
    end
  end
end
