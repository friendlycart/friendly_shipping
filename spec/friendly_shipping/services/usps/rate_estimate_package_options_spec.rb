# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/usps/rate_estimate_package_options'

RSpec.describe FriendlyShipping::Services::Usps::RateEstimatePackageOptions do
  subject { described_class.new(package_id: package_id) }
  let(:package_id) { 'my_package_id' }

  [
    :box_name,
    :commercial_pricing,
    :hold_for_pickup,
    :shipping_method,
    :transmit_dimensions,
    :rectangular,
    :return_dimensional_weight,
    :return_fees
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  describe 'box_name' do
    context 'when setting it to something that is no USPS box' do
      subject do
        described_class.new(
          package_id: package_id,
          box_name: :package
        )
      end

      it 'become "variable"' do
        expect(subject.box_name).to eq(:variable)
      end
    end
  end

  describe '#service_code' do
    subject do
      described_class.new(
        package_id: package_id,
        shipping_method: shipping_method,
        commercial_pricing: commercial_pricing,
        hold_for_pickup: hold_for_pickup
      )
    end

    let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: service_code) }
    let(:service_code) { "PRIORITY" }
    let(:commercial_pricing) { false }
    let(:hold_for_pickup) { false }

    it 'returns service code from shipping method' do
      expect(subject.service_code).to eq('PRIORITY')
    end

    context 'with no shipping method' do
      let(:shipping_method) { nil }

      it 'returns ALL' do
        expect(subject.service_code).to eq('ALL')
      end
    end

    context "with cubic shipping method" do
      let(:service_code) { "PRIORITY MAIL CUBIC" }

      it "returns unmodified service code" do
        expect(subject.service_code).to eq("PRIORITY MAIL CUBIC")
      end

      context "with commercial pricing" do
        let(:commercial_pricing) { true }

        it "returns unmodified service code" do
          expect(subject.service_code).to eq("PRIORITY MAIL CUBIC")
        end
      end

      context "with hold for pickup" do
        let(:hold_for_pickup) { true }

        it "returns unmodified service code" do
          expect(subject.service_code).to eq("PRIORITY MAIL CUBIC")
        end
      end
    end

    context 'with commercial pricing' do
      let(:commercial_pricing) { true }

      it 'appends COMMERCIAL to service code' do
        expect(subject.service_code).to eq('PRIORITY COMMERCIAL')
      end
    end

    context 'with hold for pickup' do
      let(:hold_for_pickup) { true }

      it 'appends HFP to service code' do
        expect(subject.service_code).to eq('PRIORITY HFP')
      end
    end

    context 'with commercial pricing and hold for pickup' do
      let(:commercial_pricing) { true }
      let(:hold_for_pickup) { true }

      it 'appends HFP and COMMERCIAL to service code' do
        expect(subject.service_code).to eq('PRIORITY HFP COMMERCIAL')
      end
    end
  end
end
