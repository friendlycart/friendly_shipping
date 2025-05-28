# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip::ParseCityStateResponse do
  subject(:call) { described_class.call(request: request, response: response) }

  let(:response) { double(body: response_body) }
  let(:request) { FriendlyShipping::Request.new(url: "http://www.example.com", debug: true) }

  context "with successful response" do
    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "usps_ship", "city_state", "success.json")) }

    it { is_expected.to be_success }

    it "returns location" do
      location = call.value!.data
      expect(location).to be_a(Physical::Location)
      expect(location.city).to eq("DURHAM")
      expect(location.region).to eq(described_class::USA.subregions.coded("NC"))
      expect(location.zip).to eq("27703")
      expect(location.country).to eq(described_class::USA)
    end

    it "includes request and response" do
      result = call.value!
      expect(result).to be_a(FriendlyShipping::ApiResult)
      expect(result.original_request).to eq(request)
      expect(result.original_response).to eq(response)
    end
  end

  context "with invalid zip code response" do
    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "usps_ship", "city_state", "invalid_zip.json")) }

    it { is_expected.to be_failure }

    it "returns failure" do
      failure = call.failure
      expect(failure).to be_a(FriendlyShipping::ApiResult)
      expect(failure.data).to be_a(FriendlyShipping::ApiError)
      expect(failure.data.message).to eq("Error: Invalid Zip Code.")
      expect(failure.original_request).to eq(request)
      expect(failure.original_response).to eq(response)
    end
  end

  context "with malformed response" do
    let(:response_body) { "malformed json" }

    it { is_expected.to be_failure }

    it "returns failure" do
      failure = call.failure
      expect(failure).to be_a(FriendlyShipping::ApiResult)
      expect(failure.data).to be_a(JSON::ParserError)
      expect(failure.original_request).to eq(request)
      expect(failure.original_response).to eq(response)
    end
  end
end
