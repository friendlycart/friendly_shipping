# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_json'

RSpec.describe FriendlyShipping::Services::UpsJson do
  subject(:service) { described_class.new(access_token: ENV.fetch('ACCESS_TOKEN', nil)) }

  describe '#carriers' do
    subject { service.carriers }
    let(:ups) { FriendlyShipping::Carrier.new(code: 'ups', id: 'ups', name: 'United Parcel Service') }

    it { is_expected.to be_success }

    it 'contains UPS only' do
      expect(subject.value!).to eq([ups])
    end
  end

  describe 'SHIPPING_METHODS' do
    it 'contains all valid shipping methods' do
      described_class::SHIPPING_METHODS.each do |shipping_method|
        expect(shipping_method.name).to be_present
        expect(shipping_method.service_code).to be_present
        expect(shipping_method.origin_countries).not_to be_empty
        expect(shipping_method.international? || shipping_method.domestic?).to be true
      end
    end
  end

  describe '#rates' do
    let(:destination) { FactoryBot.build(:physical_location, region: "FL", zip: '32821') }
    let(:origin) { FactoryBot.build(:physical_location, region: "NC", zip: '27703') }
    let(:shipment) { FactoryBot.build(:physical_shipment, origin: origin, destination: destination) }
    let(:shipper_number) { ENV.fetch('UPS_SHIPPER_NUMBER', nil) }

    let(:options) do
      FriendlyShipping::Services::UpsJson::RatesOptions.new(shipper_number: shipper_number)
    end

    subject { service.rates(shipment, options: options, debug: true) }

    it 'returns Physical::Rate objects wrapped in a Success Monad', vcr: { cassette_name: 'ups_json/rates/success' } do
      aggregate_failures do
        is_expected.to be_success
        expect(subject.value!.data).to be_a(Array)
        expect(subject.value!.data.first).to be_a(FriendlyShipping::Rate)
      end
    end

    context "estimating a SurePost rate" do
      let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: '93') }
      let(:options) do
        FriendlyShipping::Services::UpsJson::RatesOptions.new(
          shipping_method: shipping_method,
          shipper_number: shipper_number,
          negotiated_rates: true
        )
      end
      # SurePost only allows single packages
      let(:packages) { FactoryBot.build_list(:physical_package, 1) }
      let(:shipment) { FactoryBot.build(:physical_shipment, packages: packages, origin: origin, destination: destination) }

      it 'returns Physical::Rate objects wrapped in a Success Monad', vcr: { cassette_name: 'ups_json/rates/sure_post_success' } do
        aggregate_failures do
          is_expected.to be_success
          expect(subject.value!.data).to be_a(Array)
          expect(subject.value!.data.first).to be_a(FriendlyShipping::Rate)
        end
      end
    end

    context 'if the origin has a wrong zipcode', vcr: { cassette_name: 'ups_json/rates/failure' } do
      let(:origin) { FactoryBot.build(:physical_location, zip: '78756') }

      it 'returns a Failure with the correct error message' do
        aggregate_failures do
          is_expected.to be_failure
          expect(subject.failure.to_s).to eq('{"code"=>"111285", "message"=>"The postal code 78756 is invalid for VA United States."}')
        end
      end
    end

    context "with SurePost given as the shipping method" do
      let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: '93') }
      let(:options) do
        FriendlyShipping::Services::UpsJson::RatesOptions.new(
          shipping_method: shipping_method,
          shipper_number: shipper_number,
          negotiated_rates: true
        )
      end
      let(:shipper_number) { ENV.fetch('UPS_SHIPPER_NUMBER', nil) }
      # SurePost only allows single packages
      let(:packages) { FactoryBot.build_list(:physical_package, 1) }
      let(:shipment) { FactoryBot.build(:physical_shipment, packages: packages, origin: origin, destination: destination) }

      it 'returns Physical::Rate objects wrapped in a Success Monad', vcr: { cassette_name: 'ups_json/rates/sure_post_rate' } do
        aggregate_failures do
          is_expected.to be_success
          expect(subject.value!.data).to be_a(Array)
          expect(subject.value!.data.first).to be_a(FriendlyShipping::Rate)
        end
      end
    end

    context "with a response with a RateModifier", vcr: { cassette_name: 'ups_json/rates/rate_modifier' } do
      let(:destination) { FactoryBot.build(:physical_location, address1: '1 Richland Ave', address2: nil, city: "San Francisco", region: "CA", zip: '94110') }
      let(:origin) { FactoryBot.build(:physical_location, region: "NV", zip: '89502', address1: nil, address2: nil, city: "Reno", address_type: 'commercial') }
      let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: "03") }
      let(:options) do
        FriendlyShipping::Services::UpsJson::RatesOptions.new(shipper_number: shipper_number, shipping_method:, customer_classification: :shipper_number)
      end

      it 'returns the RateModifiers' do
        aggregate_failures do
          is_expected.to be_success
          expect(subject.value!.data).to be_a(Array)
          expect(subject.value!.data.first.data[:rate_modifier]).to be_nil
          expect(subject.value!.data[3]).to be_a(FriendlyShipping::Rate)
          expect(subject.value!.data[3].data[:packages].first[:rate_modifiers]).to eq([{ 'DTM (Destination Modifier)' => Money.new(-60, Money::Currency.new('USD')) }])
        end
      end
    end
  end

  describe '#address_classification' do
    subject { service.address_classification(address) }

    context 'with a commercial address', vcr: { cassette_name: 'ups_json/address_classification/commercial_address' } do
      let(:address) do
        FactoryBot.build(
          :physical_location,
          name: "Dag Hammerskjöld",
          address1: "800 2nd Ave",
          address2: nil,
          city: "New York",
          region: "NY",
          zip: "10017"
        )
      end

      it 'returns the address type' do
        expect(subject).to be_success
        expect(subject.value!.data).to eq('commercial')
      end
    end

    context 'with a residential address', vcr: { cassette_name: 'ups_json/address_classification/residential_address' } do
      let(:address) do
        FactoryBot.build(
          :physical_location,
          name: "John Doe",
          address1: "401 Dover St",
          address2: nil,
          city: "Westbury",
          region: "NY",
          zip: "11590"
        )
      end

      it 'returns the address type' do
        expect(subject).to be_success
        expect(subject.value!.data).to eq('residential')
      end
    end

    context 'with an unknown address', vcr: { cassette_name: 'ups_json/address_classification/unknown_address' } do
      let(:address) do
        FactoryBot.build(
          :physical_location,
          name: "Jane Doe",
          address1: "123 Does Not Exist St",
          city: "New York",
          region: "NY",
          zip: "10005"
        )
      end

      it 'returns the address type' do
        expect(subject).to be_success
        expect(subject.value!.data).to eq('unknown')
      end
    end

    context 'with an invalid address', vcr: { cassette_name: 'ups_json/address_classification/invalid_address' } do
      let(:address) do
        FactoryBot.build(
          :physical_location,
          name: "Jane Doe",
          address1: "123 Does Not Exist St",
          city: "Unknown City",
          region: "NY",
          zip: "10005"
        )
      end

      it 'returns failure with the error message' do
        expect(subject).to be_failure
        expect(subject.failure.to_s).to eq('{"code"=>"9264030", "message"=>"The state is not supported in the Customer Integration Environment."}')
      end
    end
  end

  describe '#timings', vcr: { cassette_name: 'ups_json/timings/success', decode_compressed_response: true } do
    let(:origin) do
      FactoryBot.build(
        :physical_location,
        name: 'John Doe',
        company_name: 'Company',
        address1: '10 Lovely Street',
        address2: 'Northwest',
        region: 'NC',
        city: 'Raleigh',
        zip: '27615'
      )
    end

    let(:destination) do
      FactoryBot.build(
        :physical_location,
        address1: '7007 Sea World Dr',
        city: 'Orlando',
        region: 'FL',
        zip: '32821'
      )
    end
    let(:shipment) { FactoryBot.build(:physical_shipment, origin: origin, destination: destination) }

    let(:options) { FriendlyShipping::Services::UpsJson::TimingsOptions.new }

    subject(:timings) { service.timings(shipment, options: options, debug: true) }

    it { is_expected.to be_success }

    it 'fails if the UPS api is down', vcr: { cassette_name: 'ups_json/timings/failure' } do
      expect(subject.failure.to_s).to eq('{"code"=>"10004", "message"=>"The service is temporarily unavailable"}')
    end

    describe 'contents' do
      subject { timings.value!.data }

      it 'returns rates along with the response' do
        expect(subject).to be_a(Enumerable)
        expect(subject.length).to eq(6)
        expect(subject.map(&:shipping_method).map(&:name)).to contain_exactly(
          "UPS Next Day Air® Early",
          "UPS Next Day Air®",
          "UPS Next Day Air Saver®",
          "UPS 2nd Day Air®",
          "UPS Ground",
          "UPS 3 Day Select®"
        )
        last_timing = subject.last
        expect(last_timing.shipping_method.name).to eq('UPS 3 Day Select®')
        expect(subject.map { |h| h.properties[:business_transit_days] }).to eq([1, 1, 1, 2, 2, 3])
      end
    end
  end

  xdescribe '#labels' do
    let(:origin) do
      FactoryBot.build(
        :physical_location,
        name: 'John Doe',
        company_name: 'Company',
        address1: '10 Lovely Street',
        address2: 'Northwest',
        region: 'NC',
        city: 'Raleigh',
        zip: '27615'
      )
    end

    let(:destination) do
      FactoryBot.build(
        :physical_location,
        address1: '7007 Sea World Dr',
        city: 'Orlando',
        region: 'FL',
        zip: '32821'
      )
    end

    # UPS Ground is 03
    let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: '03') }
    let(:shipper_number) { ENV.fetch('UPS_SHIPPER_NUMBER', nil) }
    let(:shipment) { FactoryBot.build(:physical_shipment, origin: origin, destination: destination) }

    subject(:labels) { service.labels(shipment, options: options, debug: true) }

    let(:options) do
      FriendlyShipping::Services::Ups::LabelOptions.new(
        shipping_method: shipping_method,
        shipper_number: shipper_number,
        negotiated_rates: true,
        customer_context: 'request-id-12345'
      )
    end

    it 'returns labels along with the response', vcr: { cassette_name: "ups_json/labels/success" } do
      expect(subject).to be_a(Dry::Monads::Result)
      first_label = subject.value!.data.first
      expect(subject.value!.data.length).to eq(2)
      expect(first_label.tracking_number).to be_present
      expect(first_label.label_data.first(5)).to eq("GIF87")
      expect(first_label.label_format).to eq("GIF")
      expect(first_label.cost).to eq(Money.new(1257, 'USD'))
      expect(first_label.shipment_cost).to eq(Money.new(2514, 'USD'))
      expect(first_label.data[:negotiated_rate]).to eq(Money.new(2479, 'USD'))
      expect(first_label.data[:customer_context]).to eq('request-id-12345')
    end

    context 'with SurePost' do
      let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: '93') }
      # SurePost only allows single packages
      let(:packages) { FactoryBot.build_list(:physical_package, 1) }
      let(:shipment) { FactoryBot.build(:physical_shipment, packages: packages, origin: origin, destination: destination) }

      it 'returns labels along with the response', vcr: { cassette_name: "ups_json/labels/surepost_success" } do
        expect(subject).to be_a(Dry::Monads::Result)
        first_label = subject.value!.data.first
        expect(subject.value!.data.length).to eq(1)
        expect(first_label.tracking_number).to be_present
        expect(first_label.label_data.first(5)).to eq("GIF89")
        expect(first_label.label_format).to eq("GIF")
        expect(first_label.cost).to eq(Money.new(1646, 'USD'))
        expect(first_label.shipment_cost).to eq(Money.new(1646, 'USD'))
        expect(first_label.data[:negotiated_rate]).to eq(Money.new(1625, 'USD'))
        expect(first_label.data[:customer_context]).to eq('request-id-12345')
      end
    end

    context 'return shipments' do
      let(:options) do
        FriendlyShipping::Services::Ups::LabelOptions.new(
          shipping_method: shipping_method,
          shipper_number: shipper_number,
          negotiated_rates: true,
          return_service: :ups_print_and_mail
        )
      end

      let(:shipment) do
        FactoryBot.build(
          :physical_shipment,
          packages: [package_1],
          origin: origin,
          destination: destination
        )
      end

      let(:package_1) { FactoryBot.build(:physical_package, items: [item_1, item_2]) }

      let(:item_1) { FactoryBot.build(:physical_item, description: 'Earrings', cost: Money.new(1000, "USD")) }
      let(:item_2) { FactoryBot.build(:physical_item, description: 'DVDs', cost: Money.new(1500, "USD")) }

      it 'returns labels along with the response', vcr: { cassette_name: "ups_json/labels/return_label" } do
        expect(subject).to be_a(Dry::Monads::Result)
        first_label = subject.value!.data.first
        expect(subject.value!.data.length).to eq(1)
        expect(first_label.tracking_number).to be_present
        expect(first_label.label_data).to be nil
        expect(first_label.label_format).to be nil
        expect(first_label.cost).to eq(Money.new(1235, 'USD'))
        expect(first_label.shipment_cost).to eq(Money.new(1235, 'USD'))
        expect(first_label.data[:negotiated_rate]).to eq(Money.new(995, 'USD'))
      end
    end

    context 'prepaid' do
      let(:options) do
        FriendlyShipping::Services::Ups::LabelOptions.new(
          shipping_method: shipping_method,
          shipper_number: shipper_number,
          billing_options: billing_options
        )
      end

      let(:billing_options) do
        FriendlyShipping::Services::Ups::LabelBillingOptions.new(
          prepay: true,
          billing_account: ENV.fetch('UPS_SHIPPER_NUMBER', nil),
          billing_zip: '27703',
          billing_country: 'US'
        )
      end

      it 'returns labels along with the response', vcr: { cassette_name: "ups_json/labels/prepaid" } do
        expect(subject).to be_a(Dry::Monads::Result)
        first_label = subject.value!.data.first
        expect(subject.value!.data.length).to eq(2)
        expect(first_label.tracking_number).to be_present
        expect(first_label.label_data.first(5)).to eq("GIF87")
        expect(first_label.label_format).to eq("GIF")
        expect(first_label.cost).to eq(Money.new(1257, 'USD'))
        expect(first_label.shipment_cost).to eq(Money.new(2514, 'USD'))
      end
    end

    context 'shipping internationally with paperless invoice' do
      let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: '54') }
      let(:destination) do
        FactoryBot.build(
          :physical_location,
          company_name: 'Free Software Foundation Europe e.V.',
          address1: 'Schoenhauser Allee 6/7',
          city: 'Berlin',
          region: 'BE',
          country: 'DE',
          zip: '10119'
        )
      end

      let(:shipment) do
        FactoryBot.build(
          :physical_shipment,
          packages: [package_1, package_2],
          origin: origin,
          destination: destination
        )
      end

      let(:package_1) { FactoryBot.build(:physical_package, items: [item_1, item_2]) }
      let(:package_2) { FactoryBot.build(:physical_package, items: [item_3, item_4]) }

      let(:item_1) { FactoryBot.build(:physical_item, description: 'Earrings', cost: Money.new(1000, "USD")) }
      let(:item_2) { FactoryBot.build(:physical_item, description: 'DVDs', cost: Money.new(1500, "USD")) }
      let(:item_3) { FactoryBot.build(:physical_item, description: 'Rice', cost: Money.new(20_000, "USD")) }
      let(:item_4) { FactoryBot.build(:physical_item, description: 'Computer', cost: Money.new(30_000, "USD")) }

      let(:options) do
        FriendlyShipping::Services::Ups::LabelOptions.new(
          shipping_method: shipping_method,
          shipper_number: shipper_number,
          paperless_invoice: true,
          terms_of_shipment: :delivery_duty_paid,
          delivery_confirmation: :delivery_confirmation_adult_signature_required
        )
      end

      it 'returns labels along with the response', vcr: { cassette_name: "ups_json/labels/international_paperless" } do
        expect(subject).to be_a(Dry::Monads::Result)
        expect(subject.value!.data.length).to eq(2)
        expect(subject.value!.data.map(&:tracking_number)).to be_present
        expect(subject.value!.data.map(&:label_data).first.first(5)).to eq("GIF87")
        expect(subject.value!.data.map(&:label_format).first).to eq("GIF")
        expect(subject.value!.data.first.data[:form_format]).to eq("PDF")
        expect(subject.value!.data.first.data[:form]).to start_with('%PDF-')
      end

      context 'when shipping to Puerto Rico' do
        let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: '03') }

        let(:destination) do
          Physical::Location.new(
            name: 'John Doe',
            company_name: 'Acme, Inc',
            address1: '1230 Calle Amapolas Apt 103',
            phone: '999-999-9999',
            city: 'Carolina',
            country: 'PR',
            zip: '00979'
          )
        end

        it 'returns labels along with the response', vcr: { cassette_name: "ups_json/labels/international_puerto_rico" } do
          expect(subject).to be_a(Dry::Monads::Result)
          expect(subject.value!.data.length).to eq(2)
          expect(subject.value!.data.map(&:tracking_number)).to be_present
          expect(subject.value!.data.map(&:label_data).first.first(5)).to eq("GIF87")
          expect(subject.value!.data.map(&:label_format).first).to eq("GIF")
          expect(subject.value!.data.first.data[:form_format]).to eq("PDF")
          expect(subject.value!.data.first.data[:form]).to start_with('%PDF-')
        end
      end
    end

    context "if the address is invalid", vcr: { cassette_name: "ups_json/labels/failure" } do
      let(:destination) do
        FactoryBot.build(
          :physical_location,
          address1: "x" * 36, # only 35 characters are allowed
          city: 'Orlando',
          region: 'FL',
          zip: '32821'
        )
      end

      it "returns a failure with a good error message" do
        is_expected.to be_failure
        expect(subject.failure.to_s).to eq("Failure: Missing or invalid ship to address line 1")
      end
    end
  end

  xdescribe '#void' do
    let(:label) { FriendlyShipping::Label.new(tracking_number: tracking_number) }
    subject { service.void(label) }

    context 'for a successful void attempt', vcr: { cassette_name: 'ups_json/void/success' } do
      let(:tracking_number) { '1Z12345E0390817264' }

      it { is_expected.to be_success }

      it 'says "Success"' do
        expect(subject.value!.data).to eq("Success")
      end
    end

    context 'for an unsuccessful void attempt', vcr: { cassette_name: 'ups_json/void/failure' } do
      let(:tracking_number) { '1Z12345E1290420899' }

      it { is_expected.to be_failure }

      it 'raises a ResponseError' do
        expect(subject.failure).to be_a(FriendlyShipping::ApiFailure)
        expect(subject.failure.data).to eq('Failure: The Pickup Request associated with this shipment has already been completed')
      end
    end
  end
end
