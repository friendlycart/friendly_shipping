# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::UpsJson::ParseJsonResponse do
  subject(:call) { described_class.call(request: request, response: response, expected_root_key: "SomeKey") }

  let(:request) { FriendlyShipping::Request.new(url: "http://www.example.com", debug: true) }
  let(:response) { double(body: response_body, headers: response_headers) }

  context "with successful response" do
    let(:response_body) { { SomeKey: "SomeValue" }.to_json }
    let(:response_headers) { nil }

    it { is_expected.to be_success }

    it "returns response body" do
      expect(call.value!).to eq("SomeKey" => "SomeValue")
    end

    context "with unexpected root key" do
      let(:response_body) { { SomeOtherKey: "SomeValue" }.to_json }

      it { is_expected.to be_failure }

      it "returns failure" do
        failure = call.failure
        expect(failure).to be_a(FriendlyShipping::ApiFailure)
        expect(failure.data).to be_a(FriendlyShipping::ApiError)
        expect(failure.data.message).to eq(described_class::UNEXPECTED_ROOT_KEY_STRING)
        expect(failure.original_request).to eq(request)
        expect(failure.original_response).to eq(response)
      end
    end

    context "with errordescription header" do
      let(:response_headers) { { errordescription: "Some error" } }

      it { is_expected.to be_failure }

      it "returns failure" do
        failure = call.failure
        expect(failure).to be_a(FriendlyShipping::ApiFailure)
        expect(failure.data).to be_a(FriendlyShipping::ApiError)
        expect(failure.data.message).to eq("Some error")
        expect(failure.original_request).to eq(request)
        expect(failure.original_response).to eq(response)
      end
    end

    context "with invalid JSON and errordescriptioon header" do
      let(:response_body) { "''" }
      let(:response_headers) { { errordescription: "It almost worked" } }

      it { is_expected.to be_failure }

      it "returns failure with the errordescription" do
        failure = call.failure
        expect(failure).to be_a(FriendlyShipping::ApiFailure)
        expect(failure.data).to be_a(FriendlyShipping::ApiError)
        expect(failure.data.message).to eq( "It almost worked")
        expect(failure.original_request).to eq(request)
        expect(failure.original_response).to eq(response)
      end
    end
  end

  context "with unsuccessful response" do
    let(:response_body) { { "SomeKey" => "SomeValue" }.to_json }
    let(:response_headers) { { errordescription: "Some error" } }

    it { is_expected.to be_failure }

    it "returns failure" do
      failure = call.failure
      expect(failure).to be_a(FriendlyShipping::ApiFailure)
      expect(failure.data).to be_a(FriendlyShipping::ApiError)
      expect(failure.data.message).to eq("Some error")
      expect(failure.original_request).to eq(request)
      expect(failure.original_response).to eq(response)
    end
  end
end
