require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::ParseCarrierResponse, vcr: { cassette_name: 'shipengine/carriers/success' } do
  subject { described_class.new(response: response).call }
  let(:response) { FriendlyShipping::Services::ShipEngine.new(token: ENV['SHIPENGINE_API_KEY']).send(:get, 'carriers').value! }
  let(:carrier) { subject.first }

  it "returns an Array of carriers", vcr: { cassette_name: 'shipengine/carriers/success' } do
    expect(subject).to be_a Array
    expect(subject.first).to be_a FriendlyShipping::Carrier
  end

  it "contains correct data in the carrier" do
    expect(carrier.id).to eq('se-76432')
    expect(carrier.name).to eq('Stamps.com')
    expect(carrier.code).to eq('stamps_com')
    expect(carrier.shipping_methods).to be_a(Array)
    expect(carrier.balance).to eq(0)
    expect(carrier.data).to be_a(Hash)
  end
end
