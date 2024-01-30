# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::ParseCreateBOLResponse do
  describe ".call" do
    subject(:call) { described_class.call(request: nil, response: response) }

    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "tforce_freight", "create_bol", "success.json")) }
    let(:response) { double(body: response_body) }

    it "has the right data" do
      expect(call.data).to eq(
        code: "OK",
        message: "success",
        bol_id: 46_176_429,
        pro_number: "020968290",
        documents: [
          {
            type: "20",
            format: "PDF",
            status: "NFO",
            data: ""
          }, {
            type: "30",
            format: "PDF",
            status: "NFO",
            data: ""
          }
        ]
      )
    end
  end
end
