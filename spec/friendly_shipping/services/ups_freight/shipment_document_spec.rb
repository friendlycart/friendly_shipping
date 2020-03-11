# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/shipment_document'

RSpec.describe FriendlyShipping::Services::UpsFreight::ShipmentDocument do
  let(:binary) { double }

  subject { described_class.new(format: "PDF", binary: binary, document_type: :label) }

  it 'store the data' do
    expect(subject.format).to eq('PDF')
    expect(subject.binary).to be binary
    expect(subject.document_type).to eq(:label)
  end
end
