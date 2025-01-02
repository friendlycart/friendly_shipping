# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps::RateEstimatePackageOptions do
  subject(:options) do
    described_class.new(
      package_id: package_id,
      **kwargs
    )
  end

  let(:package_id) { 'my_package_id' }
  let(:kwargs) { { box_name: :large_flat_rate_box } }

  [
    :box_name,
    :commercial_pricing,
    :first_class_mail_type,
    :hold_for_pickup,
    :shipping_method,
    :transmit_dimensions,
    :rectangular,
    :return_dimensional_weight,
    :return_fees
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  describe '#box_name' do
    subject(:box_name) { options.box_name }

    it { is_expected.to eq(:large_flat_rate_box) }

    context 'when setting it to something that is not a USPS box' do
      let(:kwargs) { { box_name: :package } }
      it { is_expected.to eq(:variable) }
    end
  end

  describe '#container_code' do
    subject(:container_code) { options.container_code }

    it { is_expected.to eq('LG FLAT RATE BOX') }
  end

  describe '#first_class_mail_type_code' do
    subject(:first_class_mail_type_code) { options.first_class_mail_type_code }

    let(:kwargs) { { first_class_mail_type: :letter } }
    it { is_expected.to eq('LETTER') }

    context 'with deprecated first class mail type' do
      let(:kwargs) { { first_class_mail_type: :parcel } }
      it { is_expected.to be_nil }
    end
  end

  describe '#service_code' do
    subject(:service_code) { options.service_code }

    let(:kwargs) do
      {
        shipping_method: shipping_method,
        commercial_pricing: commercial_pricing,
        hold_for_pickup: hold_for_pickup
      }
    end

    let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: service_code) }
    let(:service_code) { 'PRIORITY' }
    let(:commercial_pricing) { false }
    let(:hold_for_pickup) { false }

    it 'returns service code from shipping method' do
      expect(options.service_code).to eq('PRIORITY')
    end

    context 'with no shipping method' do
      let(:shipping_method) { nil }

      it 'returns ALL' do
        expect(options.service_code).to eq('ALL')
      end
    end

    context 'with cubic shipping method' do
      let(:service_code) { 'PRIORITY MAIL CUBIC' }

      it 'returns unmodified service code' do
        expect(options.service_code).to eq('PRIORITY MAIL CUBIC')
      end

      context 'with commercial pricing' do
        let(:commercial_pricing) { true }

        it 'returns unmodified service code' do
          expect(options.service_code).to eq('PRIORITY MAIL CUBIC')
        end
      end

      context 'with hold for pickup' do
        let(:hold_for_pickup) { true }

        it 'returns unmodified service code' do
          expect(options.service_code).to eq('PRIORITY MAIL CUBIC')
        end
      end
    end

    context 'with commercial pricing' do
      let(:commercial_pricing) { true }

      it 'appends COMMERCIAL to service code' do
        expect(options.service_code).to eq('PRIORITY COMMERCIAL')
      end
    end

    context 'with hold for pickup' do
      let(:hold_for_pickup) { true }

      it 'appends HFP to service code' do
        expect(options.service_code).to eq('PRIORITY HFP')
      end
    end

    context 'with commercial pricing and hold for pickup' do
      let(:commercial_pricing) { true }
      let(:hold_for_pickup) { true }

      it 'appends HFP and COMMERCIAL to service code' do
        expect(options.service_code).to eq('PRIORITY HFP COMMERCIAL')
      end
    end
  end
end
