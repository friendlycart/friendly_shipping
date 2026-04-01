# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::UpdateLoadOptions do
  subject(:options) { described_class.new(**attributes) }

  let(:attributes) do
    {
      load_id: 3_310_514,
      account_id: 1140
    }
  end

  it "creates options with required attributes" do
    expect(options.load_id).to eq(3_310_514)
    expect(options.account_id).to eq(1140)
  end

  describe "default values" do
    it "defaults scac to nil" do
      expect(options.scac).to be_nil
    end

    it "defaults dock_type to nil" do
      expect(options.dock_type).to be_nil
    end

    it "defaults billing_id to nil" do
      expect(options.billing_id).to be_nil
    end

    it "defaults pro_number to nil" do
      expect(options.pro_number).to be_nil
    end

    it "defaults email fields to nil" do
      expect(options.email_from).to be_nil
      expect(options.email_to).to be_nil
      expect(options.email_subject).to be_nil
      expect(options.email_body).to be_nil
    end

    it "defaults dispatch to false" do
      expect(options.dispatch).to be false
    end
  end

  describe "load_id validation" do
    context "when load_id is nil" do
      let(:attributes) { { load_id: nil, account_id: 1140 } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "load_id is required")
      end
    end
  end

  describe "scac validation" do
    context "when scac is nil" do
      let(:attributes) { { load_id: 3_310_514, account_id: 1140, scac: nil } }

      it "does not raise" do
        expect { options }.not_to raise_error
      end
    end

    context "when scac is provided" do
      let(:attributes) { { load_id: 3_310_514, account_id: 1140, scac: "UPGF" } }

      it "accepts a valid scac" do
        expect(options.scac).to eq("UPGF")
      end
    end

    context "when scac is empty" do
      let(:attributes) { { load_id: 3_310_514, account_id: 1140, scac: "" } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, "scac is required")
      end
    end
  end

  describe "dock_type validation" do
    context "when dock_type is nil" do
      let(:attributes) { { load_id: 3_310_514, account_id: 1140, dock_type: nil } }

      it "does not raise" do
        expect { options }.not_to raise_error
      end
    end

    context "when dock_type is provided" do
      let(:attributes) { { load_id: 3_310_514, account_id: 1140, dock_type: "BusinessWithDock" } }

      it "accepts a valid dock_type" do
        expect(options.dock_type).to eq("BusinessWithDock")
      end
    end

    context "when dock_type is invalid" do
      let(:attributes) { { load_id: 3_310_514, account_id: 1140, dock_type: "InvalidType" } }

      it "raises ArgumentError" do
        expect { options }.to raise_error(ArgumentError, /Invalid dock type/)
      end
    end
  end

  describe "optional fields" do
    let(:attributes) do
      {
        load_id: 3_310_514,
        account_id: 1140,
        billing_id: "2223606199",
        pro_number: "123456789",
        email_from: "shipping@widgets.com",
        email_to: "carrier@freight.com",
        email_subject: "BOL Dispatch",
        email_body: "Please dispatch this load."
      }
    end

    it "accepts all optional fields" do
      expect(options.billing_id).to eq("2223606199")
      expect(options.pro_number).to eq("123456789")
      expect(options.email_from).to eq("shipping@widgets.com")
      expect(options.email_to).to eq("carrier@freight.com")
      expect(options.email_subject).to eq("BOL Dispatch")
      expect(options.email_body).to eq("Please dispatch this load.")
    end
  end
end
