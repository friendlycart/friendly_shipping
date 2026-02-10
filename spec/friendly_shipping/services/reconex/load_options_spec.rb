# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::LoadOptions do
  subject(:options) { described_class.new(**attributes) }

  let(:attributes) do
    {
      account_id: 1140,
      scac: "UPGF"
    }
  end

  it "creates options with required attributes" do
    expect(options.account_id).to eq(1140)
    expect(options.scac).to eq("UPGF")
  end

  describe "default values" do
    it "defaults rate to false" do
      expect(options.rate).to be false
    end

    it "defaults pro_number_requested to false" do
      expect(options.pro_number_requested).to be false
    end

    it "defaults dispatch to false" do
      expect(options.dispatch).to be false
    end

    it "defaults dock_type to BusinessWithDock" do
      expect(options.dock_type).to eq("BusinessWithDock")
    end

    it "defaults destination_dock_type to dock_type" do
      expect(options.destination_dock_type).to eq("BusinessWithDock")
    end

    it "defaults origin_appointment to false" do
      expect(options.origin_appointment).to be false
    end

    it "defaults destination_appointment to false" do
      expect(options.destination_appointment).to be false
    end

    it "defaults accessorials to empty hash" do
      expect(options.accessorials).to eq({})
    end

    it "defaults shipping_quantity to 1" do
      expect(options.shipping_quantity).to eq(1)
    end

    it "defaults all_stackable to false" do
      expect(options.all_stackable).to be false
    end

    it "defaults asn_needed to false" do
      expect(options.asn_needed).to be false
    end
  end

  describe "account_id validation" do
    context "when account_id is nil" do
      let(:attributes) { { account_id: nil, scac: "UPGF" } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "account_id is required")
      end
    end
  end

  describe "scac validation" do
    context "when scac is nil" do
      let(:attributes) { { account_id: 1140, scac: nil } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "scac is required")
      end
    end

    context "when scac is empty" do
      let(:attributes) { { account_id: 1140, scac: "" } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "scac is required")
      end
    end
  end

  describe "dock_type validation" do
    context "with valid dock_type" do
      let(:attributes) { { account_id: 1140, scac: "UPGF", dock_type: "Residence" } }

      it { expect { options }.not_to raise_error }
    end

    context "with invalid dock_type" do
      let(:attributes) { { account_id: 1140, scac: "UPGF", dock_type: "InvalidDock" } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "Invalid dock type: InvalidDock")
      end
    end

    context "with invalid destination_dock_type" do
      let(:attributes) { { account_id: 1140, scac: "UPGF", destination_dock_type: "InvalidDock" } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "Invalid dock type: InvalidDock")
      end
    end
  end

  describe "accessorials validation" do
    context "with valid accessorials" do
      let(:attributes) { { account_id: 1140, scac: "UPGF", accessorials: { destination_liftgate: true } } }

      it { expect { options }.not_to raise_error }
    end

    context "with invalid accessorial key" do
      let(:attributes) { { account_id: 1140, scac: "UPGF", accessorials: { invalid_key: true } } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "Invalid accessorial(s): invalid_key")
      end
    end
  end

  describe "#options_for_structure" do
    let(:structure_options) do
      [
        FriendlyShipping::Services::Reconex::StructureOptions.new(structure_id: "struct_1")
      ]
    end

    let(:attributes) { { account_id: 1140, scac: "UPGF", structure_options: structure_options } }

    let(:structure) { double(id: "struct_1") }
    let(:unknown_structure) { double(id: "unknown") }

    it "returns structure options for matching structure" do
      result = options.options_for_structure(structure)
      expect(result.structure_id).to eq("struct_1")
    end

    it "returns default structure options for unknown structure" do
      result = options.options_for_structure(unknown_structure)
      expect(result).to be_a(FriendlyShipping::Services::Reconex::StructureOptions)
      expect(result.structure_id).to be_nil
    end
  end
end
