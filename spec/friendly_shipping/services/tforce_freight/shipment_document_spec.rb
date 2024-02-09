# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::ShipmentDocument do
  subject(:document) do
    described_class.new(
      document_type: :label,
      document_format: "PDF",
      binary: binary,
      status: "NFO"
    )
  end

  let(:binary) { double }

  it "stores the data" do
    expect(document.document_type).to eq(:label)
    expect(document.document_format).to eq("PDF")
    expect(document.binary).to be(binary)
    expect(document.status).to eq("NFO")
  end
end
