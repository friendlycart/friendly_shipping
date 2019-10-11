# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::ParseRateResponse do
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ups', 'ups_rates_api_response.xml')).read }
  let(:response) { double(body: response_body) }
  let(:request) { FriendlyShipping::Request.new(url: 'http://www.example.com') }
  let(:shipment) { FactoryBot.build(:physical_shipment) }

  subject { described_class.call(request: request, response: response, shipment: shipment) }

  it { is_expected.to be_success }

  it 'returns rates along with the response' do
    rates = subject.value!.data
    expect(rates).to be_a(Array)
    expect(rates.length).to eq(6)
    expect(rates.map(&:total_amount)).to contain_exactly(*[
      1551, 2204, 2873, 7641, 8273, 11_513
    ].map { |cents| Money.new(cents, 'USD') })
    expect(rates.map(&:shipping_method).map(&:name)).to contain_exactly(
      "UPS Ground",
      "UPS 3 Day Select",
      "UPS 2nd Day Air",
      "UPS Next Day Air Saver",
      "UPS Next Day Air Early",
      "UPS Next Day Air"
    )
  end
end
