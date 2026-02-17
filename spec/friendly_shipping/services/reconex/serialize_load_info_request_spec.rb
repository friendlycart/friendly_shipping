# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::SerializeLoadInfoRequest do
  subject(:call) { described_class.call(options: options) }

  let(:options) do
    FriendlyShipping::Services::Reconex::LoadInfoOptions.new(**attributes)
  end

  let(:attributes) do
    {
      load_ids: [123, 456],
      references: [
        { billing_id: "BILL1", po_number: "PO1", customer_id: "CUST1", customer_billing_id: "CB1" }
      ],
      status_filters: %w[Pending Booked],
      get_bill_of_lading: true,
      get_shipping_label: true,
      shipping_label_report_type_id: 900,
      get_rate_confirmation: true,
      get_carrier_docs_file: true,
      get_freight_snap_documents: true
    }
  end

  describe "loadsId" do
    it "serializes load IDs" do
      expect(call[:loadsId]).to eq([123, 456])
    end

    context "when empty" do
      let(:attributes) { {} }

      it "returns nil" do
        expect(call[:loadsId]).to be_nil
      end
    end
  end

  describe "loadsReference" do
    it "serializes references" do
      expect(call[:loadsReference]).to eq([
        { billingId: "BILL1", poNumber: "PO1", customerId: "CUST1", customerBillingId: "CB1" }
      ])
    end

    context "when empty" do
      let(:attributes) { {} }

      it "returns nil" do
        expect(call[:loadsReference]).to be_nil
      end
    end
  end

  describe "statusLoads" do
    it "serializes status filters" do
      expect(call[:statusLoads]).to eq(%w[Pending Booked])
    end

    context "when empty" do
      let(:attributes) { {} }

      it "returns nil" do
        expect(call[:statusLoads]).to be_nil
      end
    end
  end

  describe "loadInfoDocuments" do
    subject(:documents) { call[:loadInfoDocuments] }

    it "serializes getBillOfLadingDocument" do
      expect(documents[:getBillOfLadingDocument]).to be true
    end

    it "serializes getShippingLabelDocument" do
      expect(documents[:getShippingLabelDocument]).to eq(
        isRequiered: true,
        reportTypeId: 900
      )
    end

    it "serializes getRateConfirmationDocument" do
      expect(documents[:getRateConfirmationDocument]).to be true
    end

    it "serializes getCarrieDocsFile" do
      expect(documents[:getCarrieDocsFile]).to be true
    end

    it "serializes getFreightSnapDocuments" do
      expect(documents[:getFreightSnapDocuments]).to be true
    end

    context "with defaults" do
      let(:attributes) { {} }

      it "serializes all document flags as false" do
        expect(documents[:getBillOfLadingDocument]).to be false
        expect(documents[:getShippingLabelDocument]).to eq(
          isRequiered: false,
          reportTypeId: 802
        )
        expect(documents[:getRateConfirmationDocument]).to be false
        expect(documents[:getCarrieDocsFile]).to be false
        expect(documents[:getFreightSnapDocuments]).to be false
      end
    end
  end
end
