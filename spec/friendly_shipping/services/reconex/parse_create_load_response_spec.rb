# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::ParseCreateLoadResponse do
  subject(:call) { described_class.call(request: request, response: response) }

  let(:request) { FriendlyShipping::Request.new(url: "http://example.com", http_method: "POST") }

  describe "with a successful response" do
    let(:response) do
      FriendlyShipping::Response.new(
        status: 200,
        body: File.read(File.join(gem_root, "spec", "fixtures", "reconex", "create_load", "success.json")),
        headers: {}
      )
    end

    it { is_expected.to be_success }

    it "returns an ApiResult with ShipmentInformation" do
      result = call.value!
      expect(result).to be_a(FriendlyShipping::ApiResult)
      expect(result.data).to be_a(FriendlyShipping::Services::Reconex::ShipmentInformation)
    end

    it "has the correct load_id" do
      expect(call.value!.data.load_id).to eq("3310514")
    end

    it "has the correct billing_id" do
      expect(call.value!.data.billing_id).to eq("2223606199")
    end

    it "has the correct custom_id" do
      expect(call.value!.data.custom_id).to eq("0001181699")
    end

    it "has the correct po_number" do
      expect(call.value!.data.po_number).to eq("13504399")
    end

    it "has the correct customer_billing" do
      expect(call.value!.data.customer_billing).to eq(",2223441299")
    end
  end

  describe "with an error response" do
    let(:response) do
      FriendlyShipping::Response.new(
        status: 200,
        body: File.read(File.join(gem_root, "spec", "fixtures", "reconex", "create_load", "failure.json")),
        headers: {}
      )
    end

    it { is_expected.to be_failure }

    it "returns the error messages" do
      expect(call.failure.data).to include("Origin postal code is required")
      expect(call.failure.data).to include("Destination postal code is required")
    end
  end

  describe "with a response containing non-error messages" do
    let(:response) do
      body = {
        information: {
          loadId: "12345",
          proNumber: "PRO999",
          billingId: "BILL123",
          customId: nil,
          poNumber: nil,
          customerBilling: nil
        },
        messages: [
          { description: "The load was created successfully", type: "Success" },
          { description: "Rate was applied", type: "Info" }
        ]
      }.to_json

      FriendlyShipping::Response.new(status: 200, body: body, headers: {})
    end

    it { is_expected.to be_success }

    it "ignores non-error messages" do
      expect(call.value!.data.load_id).to eq("12345")
    end
  end
end
