# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight'

RSpec.describe FriendlyShipping::Services::UpsFreight do
  let(:service) { described_class.new(login: ENV['UPS_LOGIN'], password: ENV['UPS_PASSWORD'], key: ENV['UPS_KEY']) }

  describe 'carriers' do
    subject { service.carriers.value! }

    it 'has only one carrier with four shipping methods' do
      expect(subject.length).to eq(1)
      expect(subject.first.shipping_methods.map(&:service_code)).to contain_exactly(
        '308', '309', '334', '349'
      )
      expect(subject.first.shipping_methods.map(&:name)).to contain_exactly(
        'UPS Freight LTL',
        'UPS Freight LTL - Guaranteed',
        'UPS Freight LTL - Guaranteed A.M.',
        'UPS Standard LTL',
      )
    end
  end

  describe '#rate_estimates' do
    let(:shipment) { Physical::Shipment.new(packages: packages, origin: origin, destination: destination) }

    let(:origin) do
      Physical::Location.new(
        company_name: 'Developer Test 1',
        address1: '01 Developer Way',
        city: 'Richmond',
        zip: '23224',
        region: 'VA',
        country: 'US'
      )
    end

    let(:destination) do
      Physical::Location.new(
        company_name: 'Consignee Test 1',
        address1: '000 Consignee Street',
        city: 'Allanton',
        zip: '63025',
        region: 'MO',
        country: 'US'
      )
    end

    let(:packages) { [package_one, package_two] }

    let(:package_one) do
      Physical::Package.new(
        id: 'my_package_1',
        items: [item_one]
      )
    end

    let(:package_two) do
      Physical::Package.new(
        id: 'my_package_2',
        items: [item_two]
      )
    end

    let(:item_one) do
      Physical::Item.new(
        id: 'item_one',
        weight: Measured::Weight(500, :lbs)
      )
    end

    let(:item_two) do
      Physical::Item.new(
        id: 'item_two',
        weight: Measured::Weight(500, :lbs)
      )
    end

    let(:options) do
      FriendlyShipping::Services::UpsFreight::RatesOptions.new(
        shipping_method: FriendlyShipping::ShippingMethod.new(service_code: '308'),
        shipper_number: ENV['UPS_SHIPPER_NUMBER'],
        billing_address: billing_location,
        customer_context: customer_context,
        package_options: package_options
      )
    end

    let(:customer_context) { 'order-12345' }

    let(:billing_location) do
      ::Physical::Location.new(
        name: "Test Testman",
        company_name: "Acme Co.",
        address1: "Far away on the outer rim",
        city: "Durham",
        zip: "27703",
        region: "NC",
        country: "US"
      )
    end

    let(:package_options) do
      [
        FriendlyShipping::Services::UpsFreight::RatesPackageOptions.new(
          package_id: package_one.id,
          handling_unit: :pallet,
          item_options: item_one_options
        ),
        FriendlyShipping::Services::UpsFreight::RatesPackageOptions.new(
          package_id: package_two.id,
          handling_unit: :pallet,
          item_options: item_two_options
        )
      ]
    end

    let(:item_one_options) do
      [
        FriendlyShipping::Services::UpsFreight::RatesItemOptions.new(
          item_id: 'item_one',
          packaging: :carton,
          freight_class: '92.5',
          nmfc_code: '16030 sub 1'
        )
      ]
    end

    let(:item_two_options) do
      [
        FriendlyShipping::Services::UpsFreight::RatesItemOptions.new(
          item_id: 'item_two',
          packaging: :pallet,
          freight_class: '92.5',
          nmfc_code: '16030 sub 1'
        )
      ]
    end

    subject { service.rate_estimates(shipment, options: options) }

    it 'has all the right data', vcr: { cassette_name: 'ups_freight/rates/success' } do
      rates = subject.value!.data
      expect(rates.length).to eq(1)
      rate = rates.first
      expect(rate).to be_a(FriendlyShipping::Rate)
      expect(rate.total_amount).to eq(Money.new(74_709, 'USD'))
      expect(rate.shipping_method.name).to eq('UPS Freight LTL')
      expect(rate.data[:days_in_transit]).to eq(2)
    end
  end
end
