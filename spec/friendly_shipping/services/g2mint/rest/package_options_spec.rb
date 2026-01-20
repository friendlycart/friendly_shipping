# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::G2Mint::REST::PackageOptions do
  subject(:options) { described_class.new(package_id: "package") }

  it { is_expected.to be_a(FriendlyShipping::PackageOptions) }

  [
    :freight_class,
    :nmfc,
    :is_hazmat,
    :product_code,
    :packaging_config_code,
    :packaging_unit_type
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  describe "default values" do
    it "has default freight class of 50" do
      expect(options.freight_class).to eq("50")
    end

    it "has nil nmfc" do
      expect(options.nmfc).to be_nil
    end

    it "has is_hazmat as false" do
      expect(options.is_hazmat).to be(false)
    end

    it "has nil product_code" do
      expect(options.product_code).to be_nil
    end

    it "has nil packaging_config_code" do
      expect(options.packaging_config_code).to be_nil
    end

    it "has nil packaging_unit_type" do
      expect(options.packaging_unit_type).to be_nil
    end
  end

  describe "custom values" do
    subject(:options) do
      described_class.new(
        package_id: "package",
        freight_class: "250",
        nmfc: "158880-03",
        is_hazmat: true,
        product_code: "3",
        packaging_config_code: "CONFIG-1",
        packaging_unit: :box
      )
    end

    it "has the custom freight class" do
      expect(options.freight_class).to eq("250")
    end

    it "has the custom nmfc" do
      expect(options.nmfc).to eq("158880-03")
    end

    it "has is_hazmat as true" do
      expect(options.is_hazmat).to be(true)
    end

    it "has the custom product_code" do
      expect(options.product_code).to eq("3")
    end

    it "has the custom packaging_config_code" do
      expect(options.packaging_config_code).to eq("CONFIG-1")
    end

    it "has the custom packaging_unit_type" do
      expect(options.packaging_unit_type).to eq("BOX")
    end
  end
end
