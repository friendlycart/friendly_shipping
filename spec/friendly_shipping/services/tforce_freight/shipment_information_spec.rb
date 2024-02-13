# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::ShipmentInformation do
  subject(:shipment_info) do
    described_class.new(
      pro_number: "1234",
      bol_id: "2345",
      documents: docs
    )
  end

  let(:docs) { double }

  it "stores passed information" do
    expect(shipment_info.bol_id).to eq("2345")
    expect(shipment_info.pro_number).to eq("1234")
    expect(shipment_info.documents).to eq(docs)
  end
end
