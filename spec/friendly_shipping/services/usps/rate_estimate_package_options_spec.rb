# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/usps/rate_estimate_package_options'

RSpec.describe FriendlyShipping::Services::Usps::RateEstimatePackageOptions do
  subject(:options) { described_class.new(package_id: 'my_package_id') }

  [
    :box_name,
    :commercial_pricing,
    :hold_for_pickup,
    :shipping_method
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  describe 'box_name' do
    context 'when setting it to something that is no USPS box' do
      subject(:options) do
        described_class.new(
          package_id: 'my_package_id',
          box_name: :package
        )
      end

      it 'become "variable"' do
        expect(subject.box_name).to eq(:variable)
      end
    end
  end
end
