# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/usps/rate_estimate_options'

RSpec.describe FriendlyShipping::Services::Usps::RateEstimateOptions do
  let(:options) { described_class.new }
  describe '#options_for_package' do
    subject { options.options_for_package(double(package_id: 'my_package_id')) }

    it { is_expected.to be_a(FriendlyShipping::Services::Usps::RateEstimatePackageOptions) }
  end
end
