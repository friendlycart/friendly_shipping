# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups/rate_estimate_package_options'

RSpec.describe FriendlyShipping::Services::Ups::RateEstimatePackageOptions do
  subject(:options) { described_class.new(package_id: 'my_package_id') }

  [
    :transmit_dimensions
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  describe 'package_id' do
    subject { options.package_id }

    it { is_expected.to eq('my_package_id') }
  end
end
