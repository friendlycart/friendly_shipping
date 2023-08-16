# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::ParseCreateBOLResponse do
  subject { described_class.call(request: request, response: response) }

  let(:response) { double(body: response_body) }
  let(:request) { double(debug: false) }

  context "with successful response" do
    let(:response_body) { File.open(File.join(gem_root, "spec", "fixtures", "rl", "create_bol", "success.json")).read }
    let(:api_result) { subject.value! }
    let(:result) { api_result.data }

    it "returns a Hash of results" do
      expect(subject).to be_success
      expect(result).to be_a FriendlyShipping::Services::RL::ShipmentInformation
    end

    it "contains correct data" do
      expect(result.pro_number).to eq("WP7506414")
      expect(result.pickup_request_number).to eq("74201384")
    end
  end

  context "with unsuccessful response" do
    let(:response_body) { File.open(File.join(gem_root, "spec", "fixtures", "rl", "create_bol", "failure.json")).read }
    let(:api_result) { subject.failure }

    it "returns error message" do
      expect(subject).to be_failure
      expect(api_result.data).to eq(["There must be at least one item in the list"])
    end
  end
end
