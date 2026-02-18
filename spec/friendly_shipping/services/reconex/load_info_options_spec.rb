# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::LoadInfoOptions do
  subject(:options) { described_class.new(**attributes) }

  let(:attributes) { {} }

  describe "default values" do
    it "defaults load_ids to empty array" do
      expect(options.load_ids).to eq([])
    end

    it "defaults references to empty array" do
      expect(options.references).to eq([])
    end

    it "defaults status_filters to empty array" do
      expect(options.status_filters).to eq([])
    end

    it "defaults get_bill_of_lading to false" do
      expect(options.get_bill_of_lading).to be false
    end

    it "defaults get_shipping_label to false" do
      expect(options.get_shipping_label).to be false
    end

    it "defaults shipping_label_report_type_id to 802" do
      expect(options.shipping_label_report_type_id).to eq(802)
    end

    it "defaults get_rate_confirmation to false" do
      expect(options.get_rate_confirmation).to be false
    end

    it "defaults get_carrier_docs_file to false" do
      expect(options.get_carrier_docs_file).to be false
    end

    it "defaults get_freight_snap_documents to false" do
      expect(options.get_freight_snap_documents).to be false
    end
  end

  describe "with custom attributes" do
    let(:attributes) do
      {
        load_ids: [123, 456],
        references: [{ billing_id: "BILL1", po_number: "PO1" }],
        status_filters: %w[Pending Booked],
        get_bill_of_lading: true,
        get_shipping_label: true,
        shipping_label_report_type_id: 801,
        get_rate_confirmation: true,
        get_carrier_docs_file: true,
        get_freight_snap_documents: true
      }
    end

    it "assigns all attributes" do
      expect(options.load_ids).to eq([123, 456])
      expect(options.references).to eq([{ billing_id: "BILL1", po_number: "PO1" }])
      expect(options.status_filters).to eq(%w[Pending Booked])
      expect(options.get_bill_of_lading).to be true
      expect(options.get_shipping_label).to be true
      expect(options.shipping_label_report_type_id).to eq(801)
      expect(options.get_rate_confirmation).to be true
      expect(options.get_carrier_docs_file).to be true
      expect(options.get_freight_snap_documents).to be true
    end
  end

  describe "status_filters validation" do
    context "with valid statuses" do
      let(:attributes) { { status_filters: %w[Pending Quoted Booked Dispatched InTransit Delivered Canceled] } }

      it { expect { options }.not_to raise_error }
    end

    context "with invalid status" do
      let(:attributes) { { status_filters: %w[Pending InvalidStatus] } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "Invalid status filter(s): InvalidStatus")
      end
    end
  end

  describe "shipping_label_report_type_id validation" do
    context "with valid report type ID" do
      let(:attributes) { { shipping_label_report_type_id: 802 } }

      it { expect { options }.not_to raise_error }
    end

    context "with invalid report type ID" do
      let(:attributes) { { shipping_label_report_type_id: 999 } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "Invalid shipping label report type ID: 999")
      end
    end
  end

  describe "STATUSES" do
    it "includes all valid statuses" do
      expect(described_class::STATUSES).to eq(
        %w[Pending Quoted Booked Dispatched InTransit Delivered Canceled]
      )
    end
  end

  describe "SHIPPING_LABEL_REPORT_TYPES" do
    it "includes all valid report type IDs" do
      expect(described_class::SHIPPING_LABEL_REPORT_TYPES.keys).to eq(
        [800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 813, 814, 815, 816]
      )
    end
  end
end
