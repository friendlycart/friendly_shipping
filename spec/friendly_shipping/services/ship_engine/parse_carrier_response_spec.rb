require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::ParseCarrierResponse, vcr: { cassette_name: 'shipengine/carriers/success' } do
  subject { described_class.new(response: response).call }
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ship_engine', 'carriers.json')).read }
  let(:response) { double(body: response_body) }
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

  it "correctly parses shipping methods" do
    shipping_method = carrier.shipping_methods.first
    expect(shipping_method).to be_a(FriendlyShipping::ShippingMethod)
    expect(shipping_method.name).to eq("USPS First Class Mail")
    expect(shipping_method.service_code).to eq("usps_first_class_mail")
    expect(shipping_method.domestic?).to be true
    expect(shipping_method.international?).to be false
    expect(shipping_method.multi_package?).to be false
  end
end
