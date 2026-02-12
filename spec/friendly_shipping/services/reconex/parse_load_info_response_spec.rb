# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::ParseLoadInfoResponse do
  subject(:call) { described_class.call(request: request, response: response) }

  let(:request) { FriendlyShipping::Request.new(url: "http://example.com", http_method: "POST") }

  describe "with a successful response" do
    let(:response) do
      FriendlyShipping::Response.new(
        status: 200,
        body: File.read(File.join(gem_root, "spec", "fixtures", "reconex", "load_info", "success.json")),
        headers: {}
      )
    end

    it { is_expected.to be_success }

    it "returns an ApiResult with an array of LoadInfo" do
      result = call.value!
      expect(result).to be_a(FriendlyShipping::ApiResult)
      expect(result.data).to be_an(Array)
      expect(result.data.first).to be_a(FriendlyShipping::Services::Reconex::LoadInfo)
    end

    describe "first load detail" do
      subject(:load_info) { call.value!.data.first }

      it "has the correct load_id" do
        expect(load_info.load_id).to eq(2_763_982)
      end

      it "has the correct ship_date" do
        expect(load_info.ship_date).to eq("2021-09-03T00:00:00")
      end

      it "has the correct carrier_booked" do
        expect(load_info.carrier_booked).to eq("SAIA")
      end

      it "has the correct pro_number" do
        expect(load_info.pro_number).to eq("10237787450")
      end

      it "has the correct confirmation_number" do
        expect(load_info.confirmation_number).to eq("41567552")
      end

      it "has the correct load_status_detail" do
        expect(load_info.load_status_detail).to eq("Delivered")
      end

      it "has the correct total_weight" do
        expect(load_info.total_weight).to eq(1300)
      end

      it "has the correct cust_charge" do
        expect(load_info.cust_charge).to eq(386.51)
      end

      it "has the correct freight_charge" do
        expect(load_info.freight_charge).to eq(386.51)
      end

      it "has the correct mileage" do
        expect(load_info.mileage).to eq(175)
      end

      it "has the correct delivery_date" do
        expect(load_info.delivery_date).to eq("2021-09-08T00:00:00")
      end

      it "parses origin_info" do
        expect(load_info.origin_info).to eq(
          name: "Logan Clutch",
          street1: "28855 Ranney Parkway",
          street2: "",
          city: "Westlake",
          state: "OH",
          postal_code: "44145",
          country: "USA"
        )
      end

      it "parses destination_info" do
        expect(load_info.destination_info).to eq(
          name: "TIC MARINE AND HEAVY CIVIL",
          street1: "1818 WEST GWINNETT STREET",
          street2: "",
          city: "Savannah",
          state: "GA",
          postal_code: "31415",
          country: "USA"
        )
      end

      it "parses tracking_status" do
        expect(load_info.tracking_status).to eq([
          {
            time: "2021-09-08T15:00:00",
            status: "Delivered",
            message: "Delivered",
            carrier_eta: "",
            updated_on: "2021-09-08T05:00:10"
          }
        ])
      end

      it "parses documents" do
        expect(load_info.documents.length).to eq(2)
      end

      it "parses the BOL document" do
        bol = load_info.documents.find { |d| d.document_type == :bol }
        expect(bol).to be_a(FriendlyShipping::Services::Reconex::Document)
        expect(bol.filename).to eq("NewBillOfLading")
        expect(bol.format).to eq(:pdf)
        expect(bol.binary).to eq(Base64.decode64("JVBERi0xLjcKMSAwIG9iago="))
      end

      it "parses the shipping label document" do
        label = load_info.documents.find { |d| d.document_type == :label }
        expect(label).to be_a(FriendlyShipping::Services::Reconex::Document)
        expect(label.filename).to eq("ShipLabel11x8Page4x1")
        expect(label.format).to eq(:pdf)
        expect(label.binary).to eq(Base64.decode64("JVBERi0xLjcKMiAwIG9iago="))
      end

      it "skips null documents" do
        types = load_info.documents.map(&:document_type)
        expect(types).not_to include(:rate_confirmation)
        expect(types).not_to include(:carrier_docs)
      end
    end
  end

  describe "with an error response" do
    let(:response) do
      FriendlyShipping::Response.new(
        status: 200,
        body: File.read(File.join(gem_root, "spec", "fixtures", "reconex", "load_info", "failure.json")),
        headers: {}
      )
    end

    it { is_expected.to be_failure }

    it "returns the error messages" do
      expect(call.failure.data).to include("Load not found")
    end
  end

  describe "with an empty loadDetails response" do
    let(:response) do
      body = { loadDetails: [], warnings: [], errors: [] }.to_json
      FriendlyShipping::Response.new(status: 200, body: body, headers: {})
    end

    it { is_expected.to be_success }

    it "returns an empty array" do
      expect(call.value!.data).to eq([])
    end
  end
end
