# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::ParseShipmentDocument do
  describe ".call" do
    subject(:call) { described_class.call(image_data: image_data) }

    let(:image_data) do
      {
        "type" => "20",
        "format" => "PDF",
        "status" => "NFO",
        "data" => "JVBERi0="
      }
    end

    it "has the right data" do
      expect(call).to be_a(FriendlyShipping::Services::TForceFreight::ShipmentDocument)
      expect(call.document_type).to eq(:tforce_bol)
      expect(call.document_format).to eq(:pdf)
      expect(call.status).to eq("NFO")
      expect(call.binary).to eq("%PDF-")
    end
  end
end
