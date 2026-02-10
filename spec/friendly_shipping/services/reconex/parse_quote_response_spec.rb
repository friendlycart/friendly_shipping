# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::ParseQuoteResponse do
  subject(:call) { described_class.call(request: request, response: response) }

  let(:request) { FriendlyShipping::Request.new(url: "http://example.com", http_method: "POST") }

  describe "with a successful response" do
    let(:response) do
      FriendlyShipping::Response.new(
        status: 200,
        body: File.read(File.join(gem_root, "spec", "fixtures", "reconex", "quote", "success.json")),
        headers: {}
      )
    end

    it { is_expected.to be_success }

    it "returns an ApiResult with rates" do
      result = call.value!
      expect(result).to be_a(FriendlyShipping::ApiResult)
      expect(result.data).to be_an(Array)
      expect(result.data.length).to eq(2)
    end

    describe "first rate" do
      let(:rate) { call.value!.data.first }

      it "has the correct total amount" do
        expect(rate.total_amount).to eq(Money.new(43_800, "USD"))
      end

      it "has the correct carrier name" do
        expect(rate.shipping_method.name).to eq("R&L Carriers")
      end

      it "has the correct SCAC code" do
        expect(rate.shipping_method.service_code).to eq("RLCA")
      end

      it "has the cost breakdown in data" do
        expect(rate.data[:base]).to eq(275.0)
        expect(rate.data[:fsc]).to eq(33.0)
        expect(rate.data[:access]).to eq(130.0)
      end

      it "has transit time in data" do
        expect(rate.data[:transit_time]).to eq("2")
      end

      it "has carrier and scac in data" do
        expect(rate.data[:carrier]).to eq("R&L Carriers")
        expect(rate.data[:scac]).to eq("RLCA")
      end
    end

    describe "second rate" do
      let(:rate) { call.value!.data.last }

      it "has the correct total amount" do
        expect(rate.total_amount).to eq(Money.new(73_519, "USD"))
      end

      it "has the correct carrier name" do
        expect(rate.shipping_method.name).to eq("TForce Freight")
      end

      it "has the correct SCAC code" do
        expect(rate.shipping_method.service_code).to eq("UPGF")
      end

      it "has notes in data" do
        expect(rate.data[:notes]).to eq("Contract Note: Please email citysupslc@tforcefreight.com to dispatch.")
      end
    end
  end

  describe "with a response containing failed quotes" do
    let(:response) do
      body = {
        information: { resultCode: "0", resultDescription: nil },
        quotes: [
          { carrier: "Carrier A", scac: "CRRA", customerCharge: "100.00", success: true,
            base: 80.0, fsc: 10.0, access: 10.0, transitTime: "1", notes: "" },
          { carrier: "Carrier B", scac: "CRRB", customerCharge: "0.00", success: false,
            errorMessage: "No rate available" }
        ],
        errors: [],
        warnings: []
      }.to_json

      FriendlyShipping::Response.new(status: 200, body: body, headers: {})
    end

    it { is_expected.to be_success }

    it "only includes successful quotes" do
      rates = call.value!.data
      expect(rates.length).to eq(1)
      expect(rates.first.shipping_method.name).to eq("Carrier A")
    end
  end

  describe "with an error response" do
    let(:response) do
      FriendlyShipping::Response.new(
        status: 200,
        body: File.read(File.join(gem_root, "spec", "fixtures", "reconex", "quote", "failure.json")),
        headers: {}
      )
    end

    it { is_expected.to be_failure }

    it "returns the error messages" do
      expect(call.failure.data).to include("Origin postal code is required")
      expect(call.failure.data).to include("Destination postal code is required")
    end
  end

  describe "with a result code error" do
    let(:response) do
      body = {
        information: { resultCode: "1", resultDescription: "Something went wrong" },
        quotes: [],
        errors: [],
        warnings: []
      }.to_json

      FriendlyShipping::Response.new(status: 200, body: body, headers: {})
    end

    it { is_expected.to be_failure }

    it "returns the result description" do
      expect(call.failure.data).to include("Something went wrong")
    end
  end
end
