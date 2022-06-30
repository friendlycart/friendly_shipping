# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::ApiErrorHandler do
  describe ".call" do
    let(:error) { StandardError.new("oops") }

    subject { described_class.call(error) }

    it "wraps error in ApiFailure" do
      expect(subject).to be_failure
      expect(subject.failure).to be_a(FriendlyShipping::ApiFailure)
      expect(subject.failure.data).to eq(error)
      expect(subject.failure.original_request).to be_nil
      expect(subject.failure.original_response).to be_nil
    end

    context "with original request and response" do
      let(:request) { double(debug: true) }
      subject do
        described_class.call(
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
