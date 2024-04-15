# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::ParseRateResponse do
  let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ups', fixture)) }
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

  it 'returns itemized charges for the shipment' do
    rates = subject.value!.data
    expect(rates.map { |r| r.data[:itemized_charges] }).to contain_exactly(
      { 'RESIDENTIAL ADDRESS' => Money.new(360, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(415, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(415, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(415, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(415, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(415, 'USD') }
    )
  end

  it 'returns negotiated shipment rate and charges along with the response' do
    rates = subject.value!.data
    expect(rates.map { |r| r.data[:negotiated_rate] }).to contain_exactly(
      Money.new(1102, 'USD'),
      Money.new(1596, 'USD'),
      Money.new(1539, 'USD'),
      Money.new(3038, 'USD'),
      Money.new(11_513, 'USD'),
      Money.new(3265, 'USD')
    )
    expect(rates.map { |r| r.data[:negotiated_charges] }).to contain_exactly(
      { 'RESIDENTIAL ADDRESS' => Money.new(360, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(415, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(415, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(415, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(415, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(415, 'USD') }
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
          negotiated_charges: {
            'FUEL SURCHARGE' => Money.new(53, 'USD')
          },
          rate_modifiers: {},
          weight: 4.0,
          billing_weight: 4.0
        ]
      )
    end

    context 'when packages have zero rates' do
      let(:fixture) { 'ups_rates_canadian_api_response.xml' }

      it 'returns data for each package' do
        rates = subject.value!.data
        expect(rates.first.data[:packages]).to eq(
          [
            itemized_charges: {},
            negotiated_charges: {},
            rate_modifiers: {},
            weight: 1.0,
            billing_weight: 1.0
          ]
        )
      end
    end

    context 'when packages have rate modifiers' do
      let(:fixture) { 'ups_rates_with_modifiers_api_response.xml' }

      it 'returns modifiers in the data for each package' do
        ground_rate = subject.value!.data.detect { |rate| rate.shipping_method.service_code == '03' }
        expect(ground_rate.data[:packages]).to eq(
          [
            {
              transportation_charges: Money.new(5418, 'USD'),
              base_service_charge: Money.new(4303, 'USD'),
              itemized_charges: {
                'DELIVERY AREA' => Money.new(450, 'USD'),
                'FUEL SURCHARGE' => Money.new(725, 'USD'),
              },
              total_charges: Money.new(5418, 'USD'),
              negotiated_charges: {},
              rate_modifiers: {
                'DTM (Destination Modifier)' => Money.new(-60, 'USD'),
              },
              weight: 47,
              billing_weight: 47
            }, {
              transportation_charges: Money.new(2405, 'USD'),
              base_service_charge: Money.new(1689, 'USD'),
              itemized_charges: {
                'DELIVERY AREA' => Money.new(450, 'USD'),
                'FUEL SURCHARGE' => Money.new(326, 'USD'),
              },
              total_charges: Money.new(2405, 'USD'),
              negotiated_charges: {},
              rate_modifiers: {
                'DTM (Destination Modifier)' => Money.new(-60, 'USD'),
              },
              weight: 4,
              billing_weight: 8
            }
          ]
        )
      end
    end
  end
end
