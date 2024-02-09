# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::ParseInvoiceResponse do
  subject { described_class.call(request: request, response: response) }

  let(:response) { double(body: response_body) }
  let(:request) { double(debug: false) }

  context "with successful response" do
    context "with an invoice" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "rl", "get_invoice", "success.json")) }
      let(:api_result) { subject.value! }
      let(:result) { api_result.data }

      it "returns a Hash of results" do
        expect(subject).to be_success
        expect(result).to be_a FriendlyShipping::Services::RL::ShipmentDocument
      end

      it "contains correct data" do
        expect(result.format).to eq(:pdf)
        expect(result.binary).to start_with("JVB")
      end
    end

    context "with out an invoice" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "rl", "get_invoice", "missing.json")) }
      let(:api_result) { subject.failure }
      let(:result) { api_result.data }

      it "returns an array of messages" do
        expect(result).to eq(["Either you do not have access to the documents or no documents were found for the Pro."])
      end
    end
  end
end
