# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip::ParseRateEstimatesResponse do
  subject(:call) { described_class.call(request: request, response: response) }

  let(:response) { double(body: response_body) }
  let(:request) { FriendlyShipping::Request.new(url: "http://www.example.com", debug: true) }

  context "with successful response" do
    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "usps_ship", "rate_estimates", "success.json")) }

    it { is_expected.to be_success }

    it "returns rates" do
      rates = call.value!.data
      expect(rates.length).to eq(1)
      expect(rates).to all(be_a(FriendlyShipping::Rate))

      rate = rates.first
      expect(rate.total_amount).to eq(Money.new(12_625, "USD"))
      expect(rate.amounts).to eq(
        :price => Money.new(10_825, "USD"),
        "Nonstandard Volume > 2 cu ft" => Money.new(1800, "USD")
      )
      expect(rate.shipping_method.name).to eq("USPS Ground Advantage")
      expect(rate.data).to eq(
        description: "USPS Ground Advantage Nonmachinable Dimensional Rectangular",
        zone: "07"
      )
    end

    it "includes request and response" do
      result = call.value!
      expect(result).to be_a(FriendlyShipping::ApiResult)
      expect(result.original_request).to eq(request)
      expect(result.original_response).to eq(response)
    end
  end

  context "with malformed response" do
    let(:response_body) { "malformed json" }

    it { is_expected.to be_failure }

    it "returns failure" do
      failure = call.failure
      expect(failure).to be_a(FriendlyShipping::ApiResult)
      expect(failure.data).to eq("unexpected token at 'malformed json'")
      expect(failure.original_request).to eq(request)
      expect(failure.original_response).to eq(response)
    end
  end
end
