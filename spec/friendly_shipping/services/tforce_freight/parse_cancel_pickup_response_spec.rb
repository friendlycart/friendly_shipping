# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::ParseCancelPickupResponse do
  describe ".call" do
    subject(:call) { described_class.call(request: nil, response: response) }

    let(:response) { double(body: response_body) }

    context "with a successful response" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "tforce_freight", "cancel_pickup", "success.json")) }

      it { is_expected.to be_success }

      it "has all the right data" do
        expect(call.value!.data).to eq(
          response_status_code: "1",
          response_status_description: "Success",
          transaction_id: "463aebe3-ce5c-4e87-acbe-9b42954b3b92",
          confirmation_number: "WBU43190847"
        )
      end
    end

    context "with an error response (HTTP 200 with an error code in the body)" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "tforce_freight", "cancel_pickup", "failure.json")) }

      it { is_expected.to be_failure }

      it "surfaces the response status code and description" do
        expect(call.failure.to_s).to eq("0: Pickup request not found")
      end
    end
  end
end
