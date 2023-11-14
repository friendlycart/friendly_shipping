# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups/rate_estimate_options'

RSpec.describe FriendlyShipping::Services::Ups::RateEstimateOptions do
  subject(:options) { described_class.new(shipper_number: 'SECRET') }
  [
    :carbon_neutral,
    :customer_context,
    :destination_account,
    :negotiated_rates,
    :pickup_date,
    :saturday_delivery,
    :saturday_pickup,
    :shipper,
    :shipper_number,
    :shipping_method,
    :sub_version,
    :with_time_in_transit
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  describe 'sub-version validation' do
    subject(:options) { described_class.new(sub_version: 'bogus', shipper_number: 'SECRET') }

    it { expect { options }.to raise_error(ArgumentError, 'Invalid sub-version: bogus') }
  end

  describe 'default options' do
    it { expect(options.carbon_neutral).to be(true) }
    it { expect(options.negotiated_rates).to be(false) }
    it { expect(options.pickup_date).to be_nil }
    it { expect(options.saturday_delivery).to be(false) }
    it { expect(options.saturday_pickup).to be(false) }
    it { expect(options.sub_version).to eq('1707') }
    it { expect(options.with_time_in_transit).to be(false) }
  end

  describe '#options_for_package' do
    subject { options.options_for_package(double(package_id: 'my_package_id')) }

    it { is_expected.to be_a(FriendlyShipping::Services::Ups::RateEstimatePackageOptions) }
  end

  describe '#pickup_type_code' do
    subject { options.pickup_type_code }

    it { is_expected.to eq('01') }
  end

  describe '#customer_classification_code' do
    subject { options.pickup_type_code }

    it { is_expected.to eq('01') }
  end
end
