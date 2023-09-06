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
        package_options: package_options,
        pickup_request_options: pickup_request_options
      )
    end

    let(:pickup_request_options) { nil }

    let(:customer_context) { 'order-12345' }

    let(:billing_location) do
      Physical::Location.new(
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

    it 'has all the right data', vcr: { cassette_name: 'ups_freight/rates/success', match_requests_on: [:method, :uri, :content_type] } do
      rates = subject.value!.data
      expect(rates.length).to eq(1)
      rate = rates.first
      expect(rate).to be_a(FriendlyShipping::Rate)
      expect(rate.total_amount).to eq(Money.new(74_528, 'USD'))
      expect(rate.shipping_method.name).to eq('UPS Freight LTL')
      expect(rate.data[:days_in_transit]).to eq(2)
    end

    context 'with a missing destination postal code', vcr: { cassette_name: 'ups_freight/rates/failure', match_requests_on: [:method, :uri, :content_type] } do
      let(:destination) do
        Physical::Location.new(
          company_name: 'Consignee Test 1',
          city: 'Allanton',
          region: 'MO',
          country: 'US'
        )
      end

      it { is_expected.to be_failure }

      it 'has the correct error message' do
        expect(subject.failure.to_s).to eq("9360703: Missing or Invalid Postal Code(s) provided in request.")
      end
    end
  end

  describe 'labels' do
    let(:shipment) { Physical::Shipment.new(packages: packages, origin: origin, destination: destination) }

    let(:origin) do
      Physical::Location.new(
        company_name: 'Developer Test 1',
        address1: '01 Developer Way',
        phone: '919-459-4280',
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

    let(:packages) { [package_one] }

    let(:package_one) do
      Physical::Package.new(
        id: 'my_package_1',
        items: [item_one]
      )
    end

    let(:item_one) do
      Physical::Item.new(
        id: 'item_one',
        weight: Measured::Weight(500, :lbs)
      )
    end

    let(:options) do
      FriendlyShipping::Services::UpsFreight::LabelOptions.new(
        shipping_method: FriendlyShipping::ShippingMethod.new(service_code: '308'),
        shipper_number: ENV['UPS_SHIPPER_NUMBER'],
        billing_address: billing_location,
        customer_context: customer_context,
        package_options: package_options,
        document_options: document_options,
        email_options: email_options,
        pickup_options: pickup_options,
        delivery_options: delivery_options,
        handling_instructions: 'Handle with care',
        delivery_instructions: 'Up on the 20th Floor',
        pickup_instructions: 'Do not feed the bear',
        pickup_request_options: pickup_request_options
      )
    end

    let(:email_options) { [] }
    let(:pickup_options) { nil }
    let(:delivery_options) { nil }
    let(:pickup_request_options) { nil }

    let(:document_options) do
      [
        FriendlyShipping::Services::UpsFreight::LabelDocumentOptions.new(thermal: true),
        FriendlyShipping::Services::UpsFreight::LabelDocumentOptions.new(type: :ups_bol, thermal: true, size: "8x11"),
      ]
    end

    let(:customer_context) { 'order-12345' }

    let(:billing_location) do
      Physical::Location.new(
        company_name: "Candle Science",
        phone: "919-459-4280",
        address1: "1717 E Lawson St",
        city: "Durham",
        zip: "27703",
        region: "NC",
        country: "US"
      )
    end

    let(:package_options) do
      [
        FriendlyShipping::Services::UpsFreight::LabelPackageOptions.new(
          package_id: package_one.id,
          handling_unit: :pallet,
          item_options: item_one_options
        )
      ]
    end

    let(:item_one_options) do
      [
        FriendlyShipping::Services::UpsFreight::LabelItemOptions.new(
          item_id: 'item_one',
          packaging: :pallet,
          freight_class: '92.5',
          nmfc_code: '16030 sub 1'
        )
      ]
    end

    subject { service.labels(shipment, options: options) }

    it 'has all the right data', vcr: { cassette_name: 'ups_freight/labels/success', match_requests_on: [:method, :uri, :content_type] } do
      data = subject.value!.data
      expect(data).to be_a(FriendlyShipping::Services::UpsFreight::ShipmentInformation)
      expect(data.total).to eq(Money.new(45_434, 'USD'))
      expect(data.shipping_method.name).to eq('UPS Freight LTL')
      expect(data.documents.length).to eq(2)
      doc = data.documents.first
      expect(doc).to be_a(FriendlyShipping::Services::UpsFreight::ShipmentDocument)
      doc = data.documents.last
      expect(doc).to be_a(FriendlyShipping::Services::UpsFreight::ShipmentDocument)
    end

    context 'with email notifications' do
      let(:document_options) { [] }
      let(:email_options) do
        [
          FriendlyShipping::Services::UpsFreight::LabelEmailOptions.new(
            email: "user@example.com",
            undeliverable_email: "customer_service@example.com",
            email_type: :ship_notification
          ),
          FriendlyShipping::Services::UpsFreight::LabelEmailOptions.new(
            email: "user@example.com",
            undeliverable_email: "customer_service@example.com",
            email_type: :ship_notification
          )
        ]
      end

      it 'has all the right data', vcr: { cassette_name: 'ups_freight/labels/success_with_notifications', match_requests_on: [:method, :uri, :content_type] } do
        data = subject.value!.data
        expect(data).to be_a(FriendlyShipping::Services::UpsFreight::ShipmentInformation)
        expect(data.total).to eq(Money.new(45_434, 'USD'))
        expect(data.shipping_method.name).to eq('UPS Freight LTL')
        expect(data.documents.length).to eq(0)
      end
    end

    context 'with pickup options' do
      let(:document_options) { [] }
      let(:email_options) { [] }
      let(:pickup_options) do
        FriendlyShipping::Services::UpsFreight::LabelPickupOptions.new(
          lift_gate_required: true
        )
      end

      it 'has all the right data', vcr: { cassette_name: 'ups_freight/labels/success_with_pickup_lift_gate', match_requests_on: [:method, :uri, :content_type] } do
        data = subject.value!.data
        expect(data).to be_a(FriendlyShipping::Services::UpsFreight::ShipmentInformation)
        expect(data.total).to eq(Money.new(57_934, 'USD'))
        expect(data.shipping_method.name).to eq('UPS Freight LTL')
        expect(data.documents.length).to eq(0)
      end
    end

    context 'with delivery options' do
      let(:document_options) { [] }
      let(:delivery_options) do
        FriendlyShipping::Services::UpsFreight::LabelDeliveryOptions.new(
          lift_gate_required: true
        )
      end

      it 'has all the right data', vcr: { cassette_name: 'ups_freight/labels/success_with_delivery_lift_gate', match_requests_on: [:method, :uri, :content_type] } do
        data = subject.value!.data
        expect(data).to be_a(FriendlyShipping::Services::UpsFreight::ShipmentInformation)
        expect(data.total).to eq(Money.new(57_934, 'USD'))
        expect(data.shipping_method.name).to eq('UPS Freight LTL')
        expect(data.documents.length).to eq(0)
      end
    end

    context 'with pickup request options' do
      let(:pickup_request_options) do
        FriendlyShipping::Services::UpsFreight::PickupRequestOptions.new(
          pickup_time_window: Time.new(2020, 2, 7, 17, 0)..Time.new(2019, 2, 7, 19, 0),
          comments: 'Bring pitch forks, there will be hay',
          requester: requester,
          requester_email: 'me@example.com'
        )
      end

      let(:requester) do
        Physical::Location.new(
          company_name: "Candle Science",
          name: "Mike Stripe",
          phone: "919-459-4280",
        )
      end

      it 'has all the right data', vcr: { cassette_name: 'ups_freight/labels/success_with_pickup_date', match_requests_on: [:method, :uri, :content_type] } do
        data = subject.value!.data
        expect(data).to be_a(FriendlyShipping::Services::UpsFreight::ShipmentInformation)
        expect(data.total).to eq(Money.new(45_434, 'USD'))
        expect(data.shipping_method.name).to eq('UPS Freight LTL')
        expect(data.documents.length).to eq(2)
        expect(data.pickup_request_number).to eq("WBU4814270")
      end
    end
  end
end
