# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::UpsJson::ParseRatesResponse do
  subject(:call) { described_class.call(request: request, response: response, shipment: shipment) }

  let(:request) { FriendlyShipping::Request.new(url: "http://www.example.com", debug: true) }
  let(:response) { double(body: response_body, headers: {}) }
  let(:shipment) { FactoryBot.build(:physical_shipment) }
  let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "ups_json", "rates_with_rate_modifiers.json")) }

  it "returns rates for each shipping method" do
    rates = subject.value!.data
    expect(rates).to be_a(Array)
    expect(rates.length).to eq(6)
    expect(rates.map(&:total_amount)).to contain_exactly(*[
      168_74, 186_20, 82_04, 57_24, 255_80, 94_82
    ].map { |cents| Money.new(cents, 'USD') })
    expect(rates.map(&:shipping_method).map(&:name)).to contain_exactly(
      "UPS Ground",
      "UPS 3 Day Select®",
      "UPS 2nd Day Air®",
      "UPS Next Day Air Saver®",
      "UPS Next Day Air® Early",
      "UPS Next Day Air®"
    )
  end

  it "returns itemized charges for each shipping method" do
    rates = subject.value!.data
    expect(rates.map { |r| r.data[:itemized_charges] }).to contain_exactly(
      { 'RESIDENTIAL ADDRESS' => Money.new(1130, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(1240, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(1240, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(1240, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(1240, 'USD') },
      { 'RESIDENTIAL ADDRESS' => Money.new(1240, 'USD') }
    )
  end

  context "with negotiated rates" do
    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "ups_json", "rates_with_negotiated_charges.json")) }

    it "returns negotiated rates for each shipping method and the individual packages" do
      rates = subject.value!.data
      expect(rates.map { |r| r.data[:negotiated_rate] }).to contain_exactly(
        Money.new(4135, 'USD'),
        Money.new(2427, 'USD'),
        Money.new(1462, 'USD'),
        Money.new(2197, 'USD'),
        Money.new(15_202, 'USD')
      )

      expect(rates.map { |r| r.data[:packages].map { |package| package[:negotiated_charges] } }).to contain_exactly(
        [
          {
            'DELIVERY AREA' => Money.new(490, 'USD'),
            'FUEL SURCHARGE' => Money.new(586, 'USD')
          }
        ],
        [
          {
            'DELIVERY AREA' => Money.new(490, 'USD'),
            'FUEL SURCHARGE' => Money.new(344, 'USD')
          }
        ],
        [
          {
            'DELIVERY AREA' => Money.new(343, 'USD'),
            'FUEL SURCHARGE' => Money.new(199, 'USD')
          }
        ],
        [
          {
            'DELIVERY AREA' => Money.new(490, 'USD'),
            'FUEL SURCHARGE' => Money.new(311, 'USD')
          }
        ],
        [
          {
            'DELIVERY AREA' => Money.new(490, 'USD'),
            'FUEL SURCHARGE' => Money.new(2153, 'USD')
          }
        ]
      )
    end

    it "returns the changed address type for each shipping method" do
      rates = subject.value!.data
      expect(rates.map { |r| r.data[:new_address_type] }).to contain_exactly(
        "commercial",
        "commercial",
        "commercial",
        "commercial",
        "commercial"
      )
    end
  end

  describe "packages" do
    it "returns data for each package" do
      rates = subject.value!.data
      expect(rates.first.data[:packages].first).to eq(
        {
          transportation_charges: Money.new(8437, "USD"),
          base_service_charge: Money.new(6068, "USD"),
          total_charges: Money.new(8437, "USD"),
          itemized_charges: {
            "DELIVERY AREA" => Money.new(585, "USD"),
            "FUEL SURCHARGE" => Money.new(1164, "USD"),
          },
          negotiated_charges: {},
          rate_modifiers: {},
          weight: 1.0,
          billing_weight: 5.0
        }
      )
    end

    context "when packages have zero rates" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "ups_json", "ups_rates_canadian.json")) }

      it "returns data for each package" do
        rates = subject.value!.data
        expect(rates.first.data[:packages]).to eq(
          [
            { itemized_charges: {},
              negotiated_charges: {},
              rate_modifiers: {},
              weight: 10.2,
              billing_weight: 0 }
          ]
        )
      end
    end

    context "when packages have rate modifiers" do
      it "returns modifiers in the data for each package" do
        ground_rate = subject.value!.data.detect { |rate| rate.shipping_method.service_code == "03" }
        expect(ground_rate.data[:packages]).to eq(
          [
            {
              transportation_charges: Money.new(2862, "USD"),
              base_service_charge: Money.new(1395, "USD"),
              itemized_charges: {
                "DELIVERY AREA" => Money.new(570, "USD"),
                "FUEL SURCHARGE" => Money.new(392, "USD"),
              },
              total_charges: Money.new(2862, "USD"),
              negotiated_charges: {},
              rate_modifiers: {
                "DTM (Destination Modifier)" => Money.new(-60, "USD"),
              },
              weight: 1.0,
              billing_weight: 5.0
            }, {
              transportation_charges: Money.new(2862, "USD"),
              base_service_charge: Money.new(1395, "USD"),
              itemized_charges: {
                "DELIVERY AREA" => Money.new(570, "USD"),
                "FUEL SURCHARGE" => Money.new(392, "USD"),
              },
              total_charges: Money.new(2862, "USD"),
              negotiated_charges: {},
              rate_modifiers: {
                "DTM (Destination Modifier)" => Money.new(-60, "USD"),
              },
              weight: 1.0,
              billing_weight: 5.0
            }
          ]
        )
      end
    end
  end
end
