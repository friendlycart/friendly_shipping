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
    :saturday_delivery,
    :saturday_pickup,
    :shipper,
    :shipper_number,
    :shipping_method,
    :with_time_in_transit
  ].each do |message|
    it { is_expected.to respond_to(message) }
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
