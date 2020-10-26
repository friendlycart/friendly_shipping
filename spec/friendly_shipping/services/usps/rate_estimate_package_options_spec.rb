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
    :rectangular
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  describe 'box_name' do
    context 'when setting it to something that is no USPS box' do
      let(:options) do
        described_class.new(
          package_id: package_id,
          box_name: :package
        )
      end

      it 'become "variable"' do
        expect(options.box_name).to eq(:variable)
      end
    end
  end

  describe '#service_code' do
    let(:options) do
      described_class.new(
        package_id: package_id,
        shipping_method: shipping_method
      )
    end

    let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: 'PRIORITY') }

    it 'returns service code from shipping method' do
      expect(options.service_code).to eq('PRIORITY')
    end

    context 'with no shipping method' do
      let(:shipping_method) { nil }

      it 'returns ALL' do
        expect(options.service_code).to eq('ALL')
      end
    end

    context "with cubic shipping method" do
      let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: "PRIORITY MAIL CUBIC") }

      it "returns unmodified service code" do
        expect(options.service_code).to eq("PRIORITY MAIL CUBIC")
      end

      context "with commercial pricing" do
        let(:options) do
          described_class.new(
            package_id: package_id,
            shipping_method: shipping_method,
            commercial_pricing: true
          )
        end

        it "returns unmodified service code" do
          expect(options.service_code).to eq("PRIORITY MAIL CUBIC")
        end
      end

      context "with hold for pickup" do
        let(:options) do
          described_class.new(
            package_id: package_id,
            shipping_method: shipping_method,
            hold_for_pickup: true
          )
        end

        it "returns unmodified service code" do
          expect(options.service_code).to eq("PRIORITY MAIL CUBIC")
        end
      end
    end

    context 'with commercial pricing' do
      let(:options) do
        described_class.new(
          package_id: package_id,
          shipping_method: shipping_method,
          commercial_pricing: true
        )
      end

      it 'appends COMMERCIAL to service code' do
        expect(options.service_code).to eq('PRIORITY COMMERCIAL')
      end
    end

    context 'with hold for pickup' do
      let(:options) do
        described_class.new(
          package_id: package_id,
          shipping_method: shipping_method,
          hold_for_pickup: true
        )
      end

      it 'appends HFP to service code' do
        expect(options.service_code).to eq('PRIORITY HFP')
      end
    end

    context 'with commercial pricing and hold for pickup' do
      let(:options) do
        described_class.new(
          package_id: package_id,
          shipping_method: shipping_method,
          commercial_pricing: true,
          hold_for_pickup: true
        )
      end

      it 'appends HFP and COMMERCIAL to service code' do
        expect(options.service_code).to eq('PRIORITY HFP COMMERCIAL')
      end
    end
  end
end
