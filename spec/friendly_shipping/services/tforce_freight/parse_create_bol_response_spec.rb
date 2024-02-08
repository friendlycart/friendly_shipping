# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::ParseCreateBOLResponse do
  describe ".call" do
    subject(:call) { described_class.call(request: nil, response: response) }

    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "tforce_freight", "create_bol", "success.json")) }
    let(:response) { double(body: response_body) }

    it "has the right data" do
      data = call.data
      expect(data).to match(
        hash_including(
          code: "OK",
          message: "success",
          bol_id: 46_176_429,
          pro_number: "020968290"
        )
      )
      expect(data[:documents].size).to eq(2)

      document_1 = data[:documents][0]
      expect(document_1.document_type).to eq(:tforce_bol)
      expect(document_1.document_format).to eq(:pdf)
      expect(document_1.status).to eq("NFO")
      expect(document_1.binary).to start_with("%PDF-")

      document_2 = data[:documents][1]
      expect(document_2.document_type).to eq(:label)
      expect(document_2.document_format).to eq(:pdf)
      expect(document_2.status).to eq("NFO")
      expect(document_2.binary).to start_with("%PDF-")
    end
  end
end
