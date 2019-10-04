# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps do
  subject(:service) { described_class.new(login: ENV['USPS_LOGIN']) }

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
        expect(subject.value!).to be_a(Array)
        expect(subject.value!.first).to be_a(FriendlyShipping::Rate)
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
end
