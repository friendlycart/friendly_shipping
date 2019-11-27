# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/rates_options'

RSpec.describe FriendlyShipping::Services::UpsFreight::RatesOptions do
  subject(:rates_options) do
    described_class.new(
      shipper_number: 'my_shipper_number',
      billing_address: double,
      shipping_method: double
    )
  end

  it { is_expected.to be_a(FriendlyShipping::ShipmentOptions) }

  [
    :shipper_number,
    :billing_address,
    :billing_code,
    :customer_context,
    :pickup_date,
    :pickup_comments,
    :shipping_method
  ].each do |option|
    it { is_expected.to respond_to(option) }
  end

  describe 'package options' do
    let(:package) { double(package_id: nil) }

    subject { rates_options.options_for_package(package) }

    it { is_expected.to be_a(FriendlyShipping::Services::UpsFreight::RatesPackageOptions) }
  end
end
