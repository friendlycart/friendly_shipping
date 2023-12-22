# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/usps/rate_estimate_options'

RSpec.describe FriendlyShipping::Services::UspsInternational::RateEstimateOptions do
  let(:options) { described_class.new }

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::Services::UspsInternational::RateEstimatePackageOptions }
    let(:required_attrs) { {} }
  end
end
