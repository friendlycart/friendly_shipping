# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::ParseTransitTimesResponse do
  subject { described_class.call(request: request, response: response) }

  let(:response) { double(body: response_body) }
  let(:request) { double(debug: false) }

  context "with successful response" do
    let(:response_body) { File.open(File.join(gem_root, "spec", "fixtures", "rl", "transit_times", "success.json")).read }
    let(:api_result) { subject.value! }
    let(:rate) { api_result.data.first }

    it "returns an Array of timings" do
      expect(subject).to be_success
      expect(api_result.data).to be_a Array
      expect(rate).to be_a FriendlyShipping::Timing
    end

    it "contains correct data" do
      expect(rate.pickup).to eq(Time.parse("2023-08-04"))
      expect(rate.delivery).to eq(Time.parse("2023-08-14"))
      expect(rate.guaranteed).to be(false)
      expect(rate.properties).to eq(days_in_transit: 6)
      expect(rate.shipping_method.name).to eq("Standard Service")
      expect(rate.shipping_method.service_code).to eq("STD")
    end
  end

  context "with unsuccessful response" do
    let(:response_body) { File.open(File.join(gem_root, "spec", "fixtures", "rl", "transit_times", "failure.json")).read }
    let(:api_result) { subject.failure }

    it "returns error message" do
      expect(subject).to be_failure
      expect(api_result.data).to eq(["ServicePoint Zip code is required and cannot be null or empty"])
    end
  end
end
