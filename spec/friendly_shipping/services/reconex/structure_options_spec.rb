# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::StructureOptions do
  subject(:options) { described_class.new(structure_id: "struct_1", package_options: package_options) }

  let(:package_options) do
    [
      FriendlyShipping::Services::Reconex::PackageOptions.new(
        package_id: "pkg_1",
        freight_class: "70"
      )
    ]
  end

  it "creates options with valid attributes" do
    expect(options.structure_id).to eq("struct_1")
  end

  describe "#options_for_package" do
    let(:package) { double(id: "pkg_1") }
    let(:unknown_package) { double(id: "unknown") }

    it "returns package options for matching package" do
      result = options.options_for_package(package)
      expect(result.package_id).to eq("pkg_1")
      expect(result.freight_class).to eq("70")
    end

    it "returns default package options for unknown package" do
      result = options.options_for_package(unknown_package)
      expect(result).to be_a(FriendlyShipping::Services::Reconex::PackageOptions)
      expect(result.package_id).to be_nil
    end
  end

  describe "default package_options_class" do
    subject(:options) { described_class.new(structure_id: "struct_1") }

    let(:unknown_package) { double(id: "unknown") }

    it "uses Reconex::PackageOptions as default" do
      result = options.options_for_package(unknown_package)
      expect(result).to be_a(FriendlyShipping::Services::Reconex::PackageOptions)
    end
  end
end
