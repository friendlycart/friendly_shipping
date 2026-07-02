# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::LTLCarriers do
  describe ".all" do
    subject(:carriers) { described_class.all }

    it { is_expected.to all(be_a(FriendlyShipping::Carrier)) }

    it "includes the expected carriers" do
      expect(carriers.map(&:name)).to contain_exactly(
        "R+L Carriers",
        "TForce Freight",
        "SAIA",
        "FedEx Freight",
        "Southeastern Freight Lines",
        "XPO"
      )
    end
  end

  describe ".find_by_scac" do
    it "resolves confirmed SCACs to the right carrier" do
      expect(described_class.find_by_scac("RLCA").name).to eq("R+L Carriers")
      expect(described_class.find_by_scac("UPGF").name).to eq("TForce Freight")
      expect(described_class.find_by_scac("SAIA").name).to eq("SAIA")
    end

    it "resolves every SCAC of a multi-SCAC carrier" do
      expect(described_class.find_by_scac("FXFE").name).to eq("FedEx Freight")
      expect(described_class.find_by_scac("FXNL").name).to eq("FedEx Freight")
    end

    it "is case-insensitive" do
      expect(described_class.find_by_scac("rlca").name).to eq("R+L Carriers")
    end

    it "returns nil for an unknown SCAC" do
      expect(described_class.find_by_scac("NOPE")).to be_nil
    end

    it "returns nil for a nil SCAC" do
      expect(described_class.find_by_scac(nil)).to be_nil
    end
  end

  describe ".tracking_url_for" do
    it "interpolates the tracking number for a carrier with a template" do
      expect(described_class.tracking_url_for("SEFL", tracking: "123")).to eq(
        "https://www.sefl.com/webconnect/tracing?Type=PN&RefNum1=123"
      )
    end

    it "resolves multi-SCAC carriers by any of their SCACs" do
      expect(described_class.tracking_url_for("FXNL", tracking: "456")).to eq(
        "https://www.fedexfreight.com/fedextrack/?trknbr=456"
      )
    end

    it "is case-insensitive" do
      expect(described_class.tracking_url_for("cnwy", tracking: "789")).to eq(
        "https://ext-web.ltl-xpo.com/public-app/shipments?referenceNumber=789"
      )
    end

    it "builds URLs for the carriers with a dedicated service" do
      expect(described_class.tracking_url_for("RLCA", tracking: "123")).to eq(
        "https://www.rlcarriers.com/freight/shipping/shipment-tracing?pro=123&docType=PRO"
      )
      expect(described_class.tracking_url_for("UPGF", tracking: "123")).to eq(
        "https://www.tforcefreight.com/ltl/apps/Tracking?proNumbers=123"
      )
      expect(described_class.tracking_url_for("SAIA", tracking: "123")).to eq(
        "https://www.saiasecure.com/tracing/n_manifest.asp?link=y&pro=123"
      )
    end

    it "returns nil for an unknown SCAC" do
      expect(described_class.tracking_url_for("NOPE", tracking: "123")).to be_nil
    end
  end
end
