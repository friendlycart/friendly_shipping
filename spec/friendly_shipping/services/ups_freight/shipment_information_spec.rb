# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/shipment_information'

RSpec.describe FriendlyShipping::Services::UpsFreight::ShipmentInformation do
  let(:docs) { double }
  subject do
    described_class.new(
      total: Money.new(1, "USD"),
      number: '1234',
      bol_id: '2345',
      pickup_request_number: '4321',
      documents: docs,
      data: {
        cost_breakdown: {
          "Rate" => "520.75"
        }
      }
    )
  end

  it 'stores passed information' do
    expect(subject.total).to eq(Money.new(1, "USD"))
    expect(subject.documents).to eq(docs)
    expect(subject.bol_id).to eq('2345')
    expect(subject.number).to eq('1234')
    expect(subject.pickup_request_number).to eq('4321')
    expect(subject.documents).to eq(docs)
    expect(subject.data).to eq({ cost_breakdown: { "Rate" => "520.75" } })
  end
end
