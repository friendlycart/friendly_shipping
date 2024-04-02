# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip::ParseTimingsResponse do
  subject(:call) { described_class.call(request: request, response: response) }

  let(:response) { double(body: response_body) }
  let(:request) { FriendlyShipping::Request.new(url: "http://www.example.com", debug: true) }

  context "with successful response" do
    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "usps_ship", "timings", "success.json")) }

    it { is_expected.to be_success }

    it "returns timings" do
      timings = call.value!.data
      expect(timings.length).to eq(2)
      expect(timings).to all(be_a(FriendlyShipping::Timing))

      timing = timings.first
      expect(timing.pickup).to eq(Time.parse("2024-04-01 08:00"))
      expect(timing.delivery).to eq(Time.parse("2024-04-04 18:00"))
      expect(timing.guaranteed).to be(false)
      expect(timing.shipping_method.name).to eq("USPS Ground Advantage")
      expect(timing.data).to eq(
        notes: "WEIGHT_LESS_THAN_1_POUND",
        service_standard: "3",
        service_standard_message: "3 Days"
      )
    end

    it "includes request and response" do
      result = call.value!
      expect(result).to be_a(FriendlyShipping::ApiResult)
      expect(result.original_request).to eq(request)
      expect(result.original_response).to eq(response)
    end
  end

  # USPS returns a successful response (with a blank delivery estimate) even if the destination
  # zip code is invalid. We handle this response as a failure in the parser.
  #
  context "with invalid destination zip code response" do
    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "usps_ship", "timings", "invalid_dest_zip.json")) }

    it { is_expected.to be_failure }

    it "returns failure" do
      failure = call.failure
      expect(failure).to be_a(FriendlyShipping::ApiFailure)
      expect(failure.data).to eq("No timings were returned. Is the destination zip correct?")
      expect(failure.original_request).to eq(request)
      expect(failure.original_response).to eq(response)
    end
  end

  context "with malformed response" do
    let(:response_body) { "malformed json" }

    it { is_expected.to be_failure }

    it "returns failure" do
      failure = call.failure
      expect(failure).to be_a(FriendlyShipping::ApiFailure)
      expect(failure.data).to eq("unexpected token at 'malformed json'")
      expect(failure.original_request).to eq(request)
      expect(failure.original_response).to eq(response)
    end
  end
end
