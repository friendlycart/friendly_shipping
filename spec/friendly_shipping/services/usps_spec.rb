# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps do
  subject(:service) { described_class.new(login: ENV.fetch('USPS_LOGIN', nil)) }

  describe 'carriers' do
    subject { service.carriers }
    let(:usps) { FriendlyShipping::Carrier.new(code: 'usps', id: 'usps', name: 'United States Postal Service') }

    it { is_expected.to be_success }

    it 'contains UPS only' do
      expect(subject.value!).to eq([usps])
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

  describe 'rate_estimates' do
    let(:package) { FactoryBot.build(:physical_package) }
    let(:destination) { FactoryBot.build(:physical_location, region: "FL", zip: '32821') }
    let(:origin) { FactoryBot.build(:physical_location, region: "NC", zip: '27703') }
    let(:dimensions) { [8, 4, 2].map { |e| Measured::Length(e, :inches) } }
    let(:packages) do
      [
        FactoryBot.build(:physical_package, container: nil, dimensions: dimensions, id: '0'),
      ]
    end
    let(:shipment) { FactoryBot.build(:physical_shipment, packages: packages, origin: origin, destination: destination) }

    subject { service.rate_estimates(shipment) }

    it 'returns Physical::Rate objects wrapped in a Success Monad', vcr: { cassette_name: 'usps/rate_estimates/success' } do
      aggregate_failures do
        is_expected.to be_success
        expect(subject.value!.data).to be_a(Array)
        expect(subject.value!.data).to all(be_a(FriendlyShipping::Rate))
      end
    end

    context 'if the login is wrong', vcr: { cassette_name: 'usps/rate_estimates/failure' } do
      let(:service) { described_class.new(login: 'WRONG_LOGIN') }

      it 'returns a Failure with the correct error message' do
        aggregate_failures do
          is_expected.to be_failure
          expect(subject.failure.to_s).to eq("80040B1A: Authorization failure.  Perhaps username and/or password is incorrect.")
        end
      end
    end
  end

  describe 'timings' do
    let(:destination) { FactoryBot.build(:physical_location, region: "FL", zip: '32821') }
    let(:origin) { FactoryBot.build(:physical_location, region: "NC", zip: '27703') }
    let(:shipment) { FactoryBot.build(:physical_shipment, packages: [], origin: origin, destination: destination) }
    let(:options) { FriendlyShipping::Services::Usps::TimingOptions.new }

    subject { service.timings(shipment, options: options) }

    it 'returns FriendlyShipping::Timing Objects in a Success Monad', vcr: { cassette_name: 'usps/timings/success' } do
      aggregate_failures do
        is_expected.to be_success
        expect(subject.value!.data).to be_a(Array)
        expect(subject.value!.data).to all(be_a(FriendlyShipping::Timing))
      end
    end

    context 'if one mail class does not return a timing estimate' do
      let(:destination) { FactoryBot.build(:physical_location, zip: '89431') }
      let(:origin) { FactoryBot.build(:physical_location, zip: '99744') }

      it 'returns FriendlyShipping::Timing Objects in a Success Monad', vcr: { cassette_name: 'usps/timings/success_without_timing_estimate' } do
        aggregate_failures do
          is_expected.to be_success
          expect(subject.value!.data).to be_a(Array)
          expect(subject.value!.data).to all(be_a(FriendlyShipping::Timing))
          expect(subject.value!.data.last.data[:warning]).to eq(
            "The timeliness of service to destinations outside the contiguous US may be affected by the limited availability of transportation."
          )
        end
      end
    end

    context 'if one mail class has an invalid commitment sequence' do
      let(:destination) { FactoryBot.build(:physical_location, zip: '20189') }

      it 'skips the invalid commitment', vcr: { cassette_name: 'usps/timings/success_with_invalid_commitment_seq' } do
        aggregate_failures do
          is_expected.to be_success
          expect(subject.value!.data).to be_a(Array)
          expect(subject.value!.data).to all(be_a(FriendlyShipping::Timing))
        end
      end
    end

    context 'if the login is wrong', vcr: { cassette_name: 'usps/timings/failure' } do
      let(:service) { described_class.new(login: 'WRONG_LOGIN') }

      it 'returns a Failure with the correct error message' do
        aggregate_failures do
          is_expected.to be_failure
          expect(subject.failure.to_s).to eq("80040B1A: Authorization failure.  Perhaps username and/or password is incorrect.")
        end
      end
    end
  end

  describe 'city_state_lookup' do
    subject { service.city_state_lookup(location) }

    context 'with a good ZIP code', vcr: { cassette_name: 'usps/city_state_lookup/success' } do
      let(:location) { Physical::Location.new(zip: '27587', country: 'US') }

      it { is_expected.to be_success }

      it 'has correct data' do
        result_data = subject.value!.data.first
        expect(result_data.city).to eq('WAKE FOREST')
        expect(result_data.region.code).to eq('NC')
      end
    end

    context 'with a ZIP code spanning multiple states', vcr: { cassette_name: 'usps/city_state_lookup/multiple_states' } do
      let(:location) { Physical::Location.new(zip: '81137', country: 'US') }

      it { is_expected.to be_success }

      it 'has correct data' do
        result_data = subject.value!.data.first
        # Even though this ZIP code DOES span two states, USPS returns Colorado.
        expect(subject.value!.data.length).to eq(1)
        expect(result_data.city).to eq('IGNACIO')
        expect(result_data.region.code).to eq('CO')
      end
    end

    context 'with a bad ZIP code', vcr: { cassette_name: 'usps/city_state_lookup/failure' } do
      let(:location) { Physical::Location.new(zip: '00000', country: 'US') }

      it { is_expected.to be_failure }

      it 'has a nice error message' do
        expect(subject.failure.to_s).to eq('-2147219399: Invalid Zip Code.')
      end
    end
  end

  describe 'address_validation' do
    subject { service.address_validation(address) }

    context 'with a valid address', vcr: { cassette_name: 'usps/address_validation/valid_address' } do
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

    context 'with an entirely invalid address', vcr: { cassette_name: 'usps/address_validation/invalid_address' } do
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
        expect(subject.failure.to_s).to eq('-2147219401: Address Not Found.')
      end
    end

    context 'with a slightly invalid address', vcr: { cassette_name: 'usps/address_validation/correctable_address' } do
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

      it 'fails' do
        is_expected.to be_failure
        expect(subject.failure.to_s).to eq('-2147219403: Multiple addresses were found for the information you entered, and no default exists.')
      end
    end

    context 'with an incomplete address', vcr: { cassette_name: 'usps/address_validation/incomplete_address' } do
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

      it 'fails' do
        is_expected.to be_failure
        expect(subject.failure.to_s).to eq('-2147219403: Multiple addresses were found for the information you entered, and no default exists.')
      end
    end
  end
end
