# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups do
  subject(:service) { described_class.new(key: ENV['UPS_KEY'], login: ENV['UPS_LOGIN'], password: ENV['UPS_PASSWORD']) }

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

  describe '#rate_estimates' do
    let(:destination) { FactoryBot.build(:physical_location, region: "FL", zip: '32821') }
    let(:origin) { FactoryBot.build(:physical_location, region: "NC", zip: '27703') }
    let(:shipment) { FactoryBot.build(:physical_shipment, origin: origin, destination: destination) }

    subject { service.rate_estimates(shipment) }

    it 'returns Physical::Rate objects wrapped in a Success Monad', vcr: { cassette_name: 'ups/rate_estimates/success' } do
      aggregate_failures do
        is_expected.to be_success
        expect(subject.value!.data).to be_a(Array)
        expect(subject.value!.data.first).to be_a(FriendlyShipping::Rate)
      end
    end

    context 'if the origin has a wrong zipcode', vcr: { cassette_name: 'ups/rate_estimates/failure' } do
      let(:origin) { FactoryBot.build(:physical_location, zip: '78756') }

      it 'returns a Failure with the correct error message' do
        aggregate_failures do
          is_expected.to be_failure
          expect(subject.failure.to_s).to eq("Failure: The postal code 78756 is invalid for IL United States.")
        end
      end
    end
  end

  describe '#city_state_lookup' do
    subject { service.city_state_lookup(location) }

    context 'with a good ZIP code', vcr: { cassette_name: 'ups/city_state_lookup/success' } do
      let(:location) { Physical::Location.new(zip: '27587', country: 'US') }

      it { is_expected.to be_success }

      it 'has correct data' do
        result_data = subject.value!.data.first
        expect(result_data.city).to eq('WAKE FOREST')
        expect(result_data.region.code).to eq('NC')
      end
    end

    context 'with a ZIP code spanning multiple states', vcr: { cassette_name: 'ups/city_state_lookup/multiple_states' } do
      let(:location) { Physical::Location.new(zip: '81137', country: 'US') }

      it { is_expected.to be_success }

      it 'has correct data' do
        result_data = subject.value!.data.first
        # Even though this ZIP code DOES span two states, UPS returns Colorado.
        expect(subject.value!.data.length).to eq(1)
        expect(result_data.city).to eq('IGNACIO')
        expect(result_data.region.code).to eq('CO')
      end
    end

    context 'with a bad ZIP code', vcr: { cassette_name: 'ups/city_state_lookup/failure' } do
      let(:location) { Physical::Location.new(zip: '00000', country: 'US') }

      it { is_expected.to be_failure }

      it 'has a nice error message' do
        expect(subject.failure.to_s).to eq('Failure: The field, PostalCode, contains invalid data, 00000')
      end
    end
  end

  describe '#address_validation' do
    subject { service.address_validation(address) }

    context 'with a valid address', vcr: { cassette_name: 'ups/address_validation/valid_address' } do
      let(:address) do
        FactoryBot.build(
          :physical_location,
          name: "Dag Hammerskjöld",
          company_name: "United Nations",
          address1: "405 East 42nd Street",
          city: "New York",
          region: "NY",
          zip: "10017"
        )
      end

      it 'returns the address, upcased, in UPS standard form' do
        expect(subject).to be_success
        result_address = subject.value!.data.first
        expect(result_address.address1).to eq('405 E 42ND ST')
      end
    end

    context 'with an entirely invalid address', vcr: { cassette_name: 'ups/address_validation/invalid_address' } do
      let(:address) do
        FactoryBot.build(
          :physical_location,
          name: "Wat Wetlands",
          company_name: "Hogwarts School of Wizardry",
          address1: "Platform nine and a half",
          city: "New York",
          region: "NY",
          zip: "10017"
        )
      end

      it 'returns a failure indicating the address could not be validated' do
        expect(subject).to be_failure
      end
    end

    context 'with a slightly invalid address', vcr: { cassette_name: 'ups/address_validation/correctable_address' } do
      let(:address) do
        FactoryBot.build(
          :physical_location,
          name: "Dag Hammerskjöld",
          company_name: "United Nations",
          address1: "406 East 43nd Street",
          city: "New York",
          region: "NY",
          zip: "27777"
        )
      end

      it 'returns a corrected address' do
        is_expected.to be_success
        corrected_address = subject.value!.data.first
        expect(corrected_address.zip).to eq('10036-6322')
      end
    end

    context 'with an incomplete address', vcr: { cassette_name: 'ups/address_validation/incomplete_address' } do
      let(:address) do
        FactoryBot.build(
          :physical_location,
          name: "Dag Hammerskjöld",
          company_name: "United Nations",
          address1: "East 43nd Street",
          city: "New York",
          region: "NY",
          zip: "27777"
        )
      end

      it 'returns several alternatives' do
        is_expected.to be_success
        suggested_addresses = subject.value!.data
        expect(suggested_addresses.length).to eq(15)
        # All returned addresses need to have a first address line
        expect(suggested_addresses.map(&:address1).compact.length).to eq(15)
        # In this particular request, the last suggested address has a second address line.
        expect(suggested_addresses.last.address2).to eq("FRNT A-B")
      end
    end
  end

  describe '#address_classification' do
    subject { service.address_classification(address) }

    context 'with a commercial address', vcr: { cassette_name: 'ups/address_classification/commercial_address' } do
      let(:address) do
        FactoryBot.build(
          :physical_location,
          name: "Dag Hammerskjöld",
          company_name: "United Nations",
          address1: "405 East 42nd Street",
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

    context 'with a residential address', vcr: { cassette_name: 'ups/address_classification/residential_address' } do
      let(:address) do
        FactoryBot.build(
          :physical_location,
          name: "John Doe",
          address1: "401 Dover St",
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

    context 'with an unknown address', vcr: { cassette_name: 'ups/address_classification/unknown_address' } do
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
  end

  describe '#labels' do
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
    let(:shipper_number) { ENV['UPS_SHIPPER_NUMBER'] }
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

    it 'returns labels along with the response', vcr: { cassette_name: "ups/labels/success" } do
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
          billing_account: ENV['UPS_SHIPPER_NUMBER'],
          billing_zip: '27703',
          billing_country: 'US'
        )
      end

      it 'returns labels along with the response', vcr: { cassette_name: "ups/labels/prepaid" } do
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
          terms_of_shipment: :delivery_duty_paid
        )
      end

      it 'returns labels along with the response', vcr: { cassette_name: "ups/labels/international_paperless" } do
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

        it 'returns labels along with the response', vcr: { cassette_name: "ups/labels/international_puerto_rico" } do
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

    context "if the address is invalid", vcr: { cassette_name: "ups/labels/failure" } do
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
end
