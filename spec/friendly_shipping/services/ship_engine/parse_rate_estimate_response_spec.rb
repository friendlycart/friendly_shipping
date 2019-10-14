# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::ParseRateEstimateResponse do
  let(:carrier_json) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ship_engine', 'carriers.json')).read }
  let(:request) { double(debug: false) }
  let(:response) { double(body: response_body) }
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ship_engine', 'rate_estimates_success.json')).read }
  let(:carriers) { FriendlyShipping::Services::ShipEngine::ParseCarrierResponse.call(request: request, response: double(body: carrier_json)).data }
  let(:rate) { subject.value!.data.first }

  subject { described_class.call(request: request, response: response, carriers: carriers) }

  it "returns an Array of FriendlyShipping::Rate" do
    expect(subject).to be_success
    expect(subject.value!.data).to be_a Array
    expect(rate).to be_a FriendlyShipping::Rate
  end

  it "contains correct data" do
    expect(rate.shipping_method).to be_a(FriendlyShipping::ShippingMethod)
    carrier = rate.shipping_method.carrier
    expect(carrier).to eq(carriers.first)
    expect(rate.amounts.keys).to contain_exactly(:confirmation, :insurance, :other, :shipping)
    expect(rate.total_amount).to eq(Money.new(535, 'USD'))
    expect(rate.delivery_date).to eq(Time.new(2019, 6, 7, 0, 0, 0, "+00:00"))
    expect(rate.warnings).to eq([])
    expect(rate.errors).to eq([])
    expect(rate.original_request).to eq(request)
    expect(rate.original_response).to eq(response)
  end
end
