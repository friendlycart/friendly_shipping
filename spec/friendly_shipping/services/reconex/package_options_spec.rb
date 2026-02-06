# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::PackageOptions do
  subject(:options) { described_class.new(**attributes) }

  let(:attributes) do
    {
      package_id: "pkg_1",
      freight_class: "70",
      nmfc_code: "199620",
      sub_class: "01",
      packaging: "Pallets",
      description: "Soy Wax"
    }
  end

  it "creates options with valid attributes" do
    expect(options.package_id).to eq("pkg_1")
    expect(options.freight_class).to eq("70")
    expect(options.nmfc_code).to eq("199620")
    expect(options.sub_class).to eq("01")
    expect(options.packaging).to eq("Pallets")
    expect(options.description).to eq("Soy Wax")
  end

  describe "default values" do
    let(:attributes) { { package_id: "pkg_1" } }

    it "defaults packaging to Pallets" do
      expect(options.packaging).to eq("Pallets")
    end

    it "defaults other attributes to nil" do
      expect(options.freight_class).to be_nil
      expect(options.nmfc_code).to be_nil
      expect(options.sub_class).to be_nil
      expect(options.description).to be_nil
    end
  end

  describe "packaging validation" do
    context "with valid packaging" do
      let(:attributes) { { package_id: "pkg_1", packaging: "Boxes" } }

      it { expect { options }.not_to raise_error }
    end

    context "with invalid packaging" do
      let(:attributes) { { package_id: "pkg_1", packaging: "InvalidType" } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "Invalid packaging type: InvalidType")
      end
    end

    context "with nil packaging" do
      let(:attributes) { { package_id: "pkg_1", packaging: nil } }

      it { expect { options }.not_to raise_error }
    end
  end

  describe "freight_class validation" do
    context "with valid freight class" do
      let(:attributes) { { package_id: "pkg_1", freight_class: "92.5" } }

      it { expect { options }.not_to raise_error }
    end

    context "with invalid freight class" do
      let(:attributes) { { package_id: "pkg_1", freight_class: "99" } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "Invalid freight class: 99")
      end
    end

    context "with nil freight class" do
      let(:attributes) { { package_id: "pkg_1", freight_class: nil } }

      it { expect { options }.not_to raise_error }
    end
  end

  describe "nmfc_code validation" do
    context "with valid numeric nmfc_code" do
      let(:attributes) { { package_id: "pkg_1", nmfc_code: "123456" } }

      it { expect { options }.not_to raise_error }
    end

    context "with non-numeric nmfc_code" do
      let(:attributes) { { package_id: "pkg_1", nmfc_code: "ABC123" } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "NMFC code must be numeric: ABC123")
      end
    end

    context "with nil nmfc_code" do
      let(:attributes) { { package_id: "pkg_1", nmfc_code: nil } }

      it { expect { options }.not_to raise_error }
    end
  end

  describe "sub_class validation" do
    context "with valid numeric sub_class" do
      let(:attributes) { { package_id: "pkg_1", sub_class: "01" } }

      it { expect { options }.not_to raise_error }
    end

    context "with non-numeric sub_class" do
      let(:attributes) { { package_id: "pkg_1", sub_class: "A1" } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "Sub class must be numeric: A1")
      end
    end

    context "with nil sub_class" do
      let(:attributes) { { package_id: "pkg_1", sub_class: nil } }

      it { expect { options }.not_to raise_error }
    end
  end

  describe "PACKAGING_TYPES" do
    it "includes common packaging types" do
      expect(described_class::PACKAGING_TYPES).to include("Pallets", "Boxes", "Cartons", "Drums")
    end
  end

  describe "FREIGHT_CLASSES" do
    it "includes standard freight classes" do
      expect(described_class::FREIGHT_CLASSES).to include("50", "70", "100", "500")
    end
  end
end
