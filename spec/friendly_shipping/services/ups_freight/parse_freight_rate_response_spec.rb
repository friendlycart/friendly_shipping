# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/parse_freight_rate_response'

RSpec.describe FriendlyShipping::Services::UpsFreight::ParseFreightRateResponse do
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ups_freight', 'rate_estimates', 'success.json')).read }
  let(:response) { double(body: response_body) }
  let(:request) { FriendlyShipping::Request.new(url: 'http://www.example.com') }

  subject { described_class.call(request: request, response: response) }

  it 'has the right data' do
    rates = subject.data
    expect(rates.length).to eq(1)
    rate = rates.first
    expect(rate).to be_a(FriendlyShipping::Rate)
    expect(rate.total_amount).to eq(Money.new(75_673, 'USD'))
    expect(rate.shipping_method.name).to eq('UPS Freight LTL')
  end
end
