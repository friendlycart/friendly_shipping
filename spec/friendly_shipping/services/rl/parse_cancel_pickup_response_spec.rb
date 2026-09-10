# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::ParseCancelPickupResponse do
  describe ".call" do
    subject(:call) { described_class.call(request: nil, response: response) }

    let(:response) { double(body: response_body) }

    context "with a successful response" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "rl", "cancel_pickup", "success.json")) }

      it { is_expected.to be_success }

      it "returns the messages from the API" do
        expect(call.value!.data).to eq(["Pickup Request 74201384 has been cancelled."])
      end
    end

    context "with a null errors array" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "rl", "cancel_pickup", "unknown_pickup_request.json")) }

      it { is_expected.to be_success }

      it "returns no messages" do
        expect(call.value!.data).to eq([])
      end
    end

    context "with an error response (HTTP 200 with errors in the body)" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "rl", "cancel_pickup", "failure.json")) }

      it { is_expected.to be_failure }

      it "returns the error messages" do
        expect(call.failure.data).to eq(["Pickup Request could not be found"])
      end
    end
  end
end
