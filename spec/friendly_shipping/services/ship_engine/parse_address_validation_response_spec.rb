# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::ParseAddressValidationResponse do
  subject(:call) { described_class.call(request: request, response: response) }

  let(:request) { double(debug: true) }
  let(:response) { double(body: response_body) }

  let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "ship_engine", "address_validation_success.json")) }

  it "contains correct data" do
    result = call
    expect(result).to be_success
    expect(result.value!).to be_a(FriendlyShipping::ApiResult)
    expect(result.value!.data).to be_a(Physical::Location)
    expect(subject.value!.original_request).to eq(request)
    expect(subject.value!.original_response).to eq(response)

    location = result.value!.data
    expect(location.name).to eq("JOHN SMITH")
    expect(location.phone).to eq("123-123-1234")
    expect(location.email).to be_nil
    expect(location.company_name).to eq("ACME INC")
    expect(location.address1).to eq("123 MAPLE AVE STE 456")
    expect(location.address2).to eq("")
    expect(location.address3).to be_nil
    expect(location.city).to eq("RICHMOND")
    expect(location.region.code).to eq("VA")
    expect(location.zip).to eq("23226")
    expect(location.country.code).to eq("US")
    expect(location.address_type).to eq("unknown")
  end

  context "when response has errors" do
    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "ship_engine", "address_validation_failure.json")) }

    it "contains correct data" do
      result = call
      expect(result).to be_failure
      expect(result.failure).to be_a(FriendlyShipping::ApiFailure)
      expect(result.failure.data).to eq("Address not found")
      expect(subject.failure.original_request).to eq(request)
      expect(subject.failure.original_response).to eq(response)
    end
  end

  context "when response is not parseable" do
    let(:response_body) { "this is not json" }

    it "contains correct data" do
      result = call
      expect(result).to be_failure
      expect(result.failure).to be_a(FriendlyShipping::ApiFailure)
      expect(result.failure.data).to be_a(JSON::ParserError)
      expect(subject.failure.original_request).to eq(request)
      expect(subject.failure.original_response).to eq(response)
    end
  end
end
