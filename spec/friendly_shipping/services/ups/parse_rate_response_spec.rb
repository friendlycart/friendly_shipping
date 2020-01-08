# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::ParseRateResponse do
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ups', fixture)).read }
  let(:fixture) { 'ups_rates_api_response.xml' }
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

  describe 'address type changed' do
    context 'when changed to residential' do
      let(:fixture) { 'ups_rates_address_type_residential_api_response.xml' }
      it { is_expected.to be_success }

      it 'returns rates with new address type' do
        rates = subject.value!.data
        expect(rates.first.warnings).to include('Ship To Address Classification is changed from Commercial to Residential')
        expect(rates.first.data[:new_address_type]).to eq('residential')
      end
    end

    context 'when changed to commercial' do
      let(:fixture) { 'ups_rates_address_type_commercial_api_response.xml' }
      it { is_expected.to be_success }

      it 'returns rates with new address type' do
        rates = subject.value!.data
        expect(rates.first.warnings).to include('Ship To Address Classification is changed from Residential to Commercial')
        expect(rates.first.data[:new_address_type]).to eq('commercial')
      end
    end

    context 'when unchanged' do
      let(:fixture) { 'ups_rates_api_response.xml' }
      it { is_expected.to be_success }

      it 'returns rates without address type' do
        rates = subject.value!.data
        expect(rates.first.warnings).to eq(['Your invoice may vary from the displayed reference rates'])
        expect(rates.first.data).to_not have_key(:new_address_type)
      end
    end
  end

  describe 'packages' do
    it 'returns data for each package' do
      rates = subject.value!.data
      expect(rates.first.data[:packages]).to eq(
        [
          transportation_charges: Money.new(1551, 'USD'),
          base_service_charge: Money.new(1086, 'USD'),
          total_charges: Money.new(1551, 'USD'),
          itemized_charges: {
            'FUEL SURCHARGE' => Money.new(105, 'USD')
          },
          weight: 4.0,
          billing_weight: 4.0
        ]
      )
    end
  end
end
