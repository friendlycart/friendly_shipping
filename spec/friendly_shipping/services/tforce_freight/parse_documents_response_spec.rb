# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::ParseDocumentsResponse do
  describe ".call" do
    subject(:call) { described_class.call(request: nil, response: response) }

    let(:response) { double(body: response_body) }

    context "with a successful response" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "tforce_freight", "documents", "success.json")) }

      it { is_expected.to be_success }

      it "returns an array of shipment documents" do
        documents = call.value!.data
        expect(documents).to be_a(Array)
        expect(documents.size).to eq(2)
        expect(documents).to all(be_a(FriendlyShipping::Services::TForceFreight::ShipmentDocument))
      end

      it "has the right data" do
        document_1 = call.value!.data[0]
        expect(document_1.document_type).to eq(:claims)
        expect(document_1.document_format).to eq(:pdf)
        expect(document_1.status).to eq("Active")
        expect(document_1.binary).to start_with("%PDF-")

        document_2 = call.value!.data[1]
        expect(document_2.document_type).to eq(:bill_of_lading)
        expect(document_2.document_format).to eq(:pdf)
        expect(document_2.status).to eq("Active")
        expect(document_2.binary).to start_with("%PDF-")
      end
    end

    context "with an error response (HTTP 200 with an error code in the body)" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "tforce_freight", "documents", "failure.json")) }

      it { is_expected.to be_failure }

      it "surfaces the response status code and message" do
        expect(call.failure.to_s).to eq("IMG_000201: MyLTL Enrollment is required")
      end
    end
  end
end
