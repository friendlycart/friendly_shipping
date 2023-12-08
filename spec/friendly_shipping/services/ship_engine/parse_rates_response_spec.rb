# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::ParseRatesResponse do
  let(:carrier_json) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ship_engine', 'apc_carriers.json')) }
  let(:request) { double(debug: true) }
  let(:response) { double(body: response_body) }
  let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ship_engine', 'apc_rates_success.json')) }
  let(:carriers) { FriendlyShipping::Services::ShipEngine::ParseCarrierResponse.call(request: request, response: double(body: carrier_json)).data }
  let(:options) { FriendlyShipping::Services::ShipEngine::RatesOptions.new(carriers: carriers, service_code: "se-666777") }
  let(:rate_estimate) { subject.value!.data.first }

  subject { described_class.call(request: request, response: response, options: options) }

  it "returns an Array of FriendlyShipping::Rate" do
    expect(subject).to be_success
    expect(subject.value!.data).to be_a Array
    expect(rate_estimate).to be_a FriendlyShipping::Rate
  end

  it "contains correct data" do
    expect(rate_estimate.shipping_method).to be_a(FriendlyShipping::ShippingMethod)
    carrier = rate_estimate.shipping_method.carrier
    expect(carrier).to eq(carriers.first)
    expect(rate_estimate.amounts.keys).to contain_exactly(:confirmation, :insurance, :other, :shipping)
    expect(rate_estimate.total_amount).to eq(Money.new(1297, 'USD'))
    expect(rate_estimate.delivery_date).to be_nil
    expect(rate_estimate.warnings).to eq([])
    expect(rate_estimate.errors).to eq([])
    expect(rate_estimate.data).to eq({})
    expect(subject.value!.original_request).to eq(request)
    expect(subject.value!.original_response).to eq(response)
  end
end
