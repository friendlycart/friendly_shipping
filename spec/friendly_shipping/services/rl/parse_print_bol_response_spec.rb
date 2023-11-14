# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::ParsePrintBOLResponse do
  subject { described_class.call(request: request, response: response) }

  let(:response) { double(body: response_body) }
  let(:request) { double(debug: false) }

  context "with successful response" do
    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "rl", "print_bol", "success.json")) }
    let(:api_result) { subject.value! }
    let(:result) { api_result.data }

    it "returns a Hash of results" do
      expect(subject).to be_success
      expect(result).to be_a FriendlyShipping::Services::RL::ShipmentDocument
    end

    it "contains correct data" do
      expect(result.format).to eq(:pdf)
      expect(result.document_type).to eq(:rl_bol)
      expect(result.binary).to start_with("%PDF-")
    end
  end
end
