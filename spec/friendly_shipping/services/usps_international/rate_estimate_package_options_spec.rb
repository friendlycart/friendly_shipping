# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/usps_international/rate_estimate_package_options'

RSpec.describe FriendlyShipping::Services::UspsInternational::RateEstimatePackageOptions do
  subject { described_class.new(package_id: package_id) }
  let(:package_id) { 'my_package_id' }

  [
    :box_name,
    :commercial_pricing,
    :commercial_plus_pricing,
    :mail_type,
    :rectangular,
    :shipping_method,
    :transmit_dimensions
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  describe 'commercial_pricing' do
    it 'is Y when true' do
      expect(described_class.new(
          package_id: package_id,
          commercial_pricing: true,
        ).commercial_pricing).to eq("Y")
    end

    it 'is N when false' do
      expect(described_class.new(
          package_id: package_id,
        ).commercial_pricing).to eq("N")
    end
  end

  describe 'commercial_plus_pricing' do
    it 'is Y when true' do
      expect(described_class.new(
          package_id: package_id,
          commercial_plus_pricing: true,
        ).commercial_plus_pricing).to eq("Y")
    end

    it 'is N when false' do
      expect(described_class.new(
          package_id: package_id,
        ).commercial_plus_pricing).to eq("N")
    end
  end
end
