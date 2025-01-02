# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::RatesOptions do
  subject(:options) do
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
    :shipping_method,
    :pickup_request_options,
    :commodity_information_generator
  ].each do |option|
    it { is_expected.to respond_to(option) }
  end

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::Services::UpsFreight::RatesPackageOptions }
    let(:required_attrs) do
      {
        shipper_number: 'my_shipper_number',
        billing_address: double,
        shipping_method: double
      }
    end
  end

  describe 'package options' do
    let(:package) { double(package_id: nil) }

    subject { options.options_for_package(package) }

    it { is_expected.to be_a(FriendlyShipping::Services::UpsFreight::RatesPackageOptions) }
  end
end
