# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::ApiErrorHandler do
  describe ".call" do
    let(:response) { double(body: { httpCode: "500" }.to_json) }
    let(:error) { RestClient::Exception.new(response) }

    subject { described_class.new.call(error) }

    it "wraps error in ApiFailure" do
      expect(subject).to be_failure
      expect(subject.failure).to be_a(FriendlyShipping::ApiFailure)
      expect(subject.failure.data).to be_a(FriendlyShipping::ApiError)
      expect(subject.failure.data.cause).to eq(error)
      expect(subject.failure.original_request).to be_nil
      expect(subject.failure.original_response).to be_nil
    end

    context "with custom API error class" do
      subject do
        described_class.new(
          api_error_class: FriendlyShipping::Services::UpsFreight::ApiError
        ).call(error)
      end

      it "wraps error in custom class" do
        expect(subject.failure).to be_a(FriendlyShipping::ApiFailure)
        expect(subject.failure.data).to be_a(FriendlyShipping::Services::UpsFreight::ApiError)
        expect(subject.failure.data.cause).to eq(error)
      end
    end

    context "with original request and response" do
      let(:request) { double(debug: true) }

      subject do
        described_class.new.call(
          error,
          original_request: request,
          original_response: "response"
        )
      end

      it "sets original request and response" do
        expect(subject.failure.original_request).to eq(request)
        expect(subject.failure.original_response).to eq("response")
      end
    end
  end
end
