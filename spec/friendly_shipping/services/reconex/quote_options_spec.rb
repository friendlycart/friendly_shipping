# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::QuoteOptions do
  subject(:options) { described_class.new(**attributes) }

  let(:attributes) do
    {
      must_arrive_by_date: Time.parse("2025-07-25T12:00:00Z"),
      dock_type: "BusinessWithDock",
      destination_dock_type: "Residence",
      total_quantity: "2",
      total_units: "Pallets",
      accessorials: { destination_liftgate: true }
    }
  end

  it "creates options with valid attributes" do
    expect(options.must_arrive_by_date).to eq(Time.parse("2025-07-25T12:00:00Z"))
    expect(options.dock_type).to eq("BusinessWithDock")
    expect(options.destination_dock_type).to eq("Residence")
    expect(options.total_quantity).to eq("2")
    expect(options.total_units).to eq("Pallets")
    expect(options.accessorials).to eq(destination_liftgate: true)
  end

  describe "default values" do
    let(:attributes) { {} }

    it "defaults dock_type to BusinessWithDock" do
      expect(options.dock_type).to eq("BusinessWithDock")
    end

    it "defaults destination_dock_type to dock_type" do
      expect(options.destination_dock_type).to eq("BusinessWithDock")
    end

    it "defaults total_quantity to 1" do
      expect(options.total_quantity).to eq("1")
    end

    it "defaults total_units to Pallets" do
      expect(options.total_units).to eq("Pallets")
    end

    it "defaults accessorials to empty hash" do
      expect(options.accessorials).to eq({})
    end
  end

  describe "destination_dock_type" do
    context "when not specified" do
      let(:attributes) { { dock_type: "Residence" } }

      it "defaults to dock_type value" do
        expect(options.destination_dock_type).to eq("Residence")
      end
    end

    context "when explicitly specified" do
      let(:attributes) { { dock_type: "BusinessWithDock", destination_dock_type: "Residence" } }

      it "uses the specified value" do
        expect(options.dock_type).to eq("BusinessWithDock")
        expect(options.destination_dock_type).to eq("Residence")
      end
    end
  end

  describe "dock_type validation" do
    context "with valid dock_type" do
      let(:attributes) { { dock_type: "Residence" } }

      it { expect { options }.not_to raise_error }
    end

    context "with invalid dock_type" do
      let(:attributes) { { dock_type: "InvalidDock" } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "Invalid dock type: InvalidDock")
      end
    end

    context "with invalid destination_dock_type" do
      let(:attributes) { { dock_type: "BusinessWithDock", destination_dock_type: "InvalidDock" } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "Invalid dock type: InvalidDock")
      end
    end
  end

  describe "total_units validation" do
    context "with valid total_units" do
      let(:attributes) { { total_units: "Boxes" } }

      it { expect { options }.not_to raise_error }
    end

    context "with invalid total_units" do
      let(:attributes) { { total_units: "InvalidUnits" } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "Invalid total units: InvalidUnits")
      end
    end
  end

  describe "accessorials validation" do
    context "with valid accessorials" do
      let(:attributes) { { accessorials: { destination_liftgate: true, origin_inside_pickup: false } } }

      it { expect { options }.not_to raise_error }
    end

    context "with invalid accessorial key" do
      let(:attributes) { { accessorials: { invalid_accessorial: true } } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "Invalid accessorial(s): invalid_accessorial")
      end
    end

    context "with string keys" do
      let(:attributes) { { accessorials: { "destination_liftgate" => true } } }

      it { expect { options }.not_to raise_error }
    end
  end

  describe "#options_for_structure" do
    let(:structure_options) do
      [
        FriendlyShipping::Services::Reconex::StructureOptions.new(structure_id: "struct_1")
      ]
    end

    let(:attributes) { { structure_options: structure_options } }

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

  describe "DOCK_TYPES" do
    it "includes common dock types" do
      expect(described_class::DOCK_TYPES).to include(
        "BusinessWithDock", "BusinessWithOutDock", "Residence", "Construction"
      )
    end
  end

  describe "ACCESSORIALS" do
    it "includes common accessorials" do
      expect(described_class::ACCESSORIALS).to include(
        :destination_liftgate, :origin_liftgate, :destination_inside_delivery, :origin_inside_pickup
      )
    end
  end
end
