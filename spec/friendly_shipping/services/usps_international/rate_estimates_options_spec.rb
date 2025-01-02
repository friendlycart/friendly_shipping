# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UspsInternational::RateEstimateOptions do
  let(:options) { described_class.new }

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::Services::UspsInternational::RateEstimatePackageOptions }
    let(:required_attrs) { {} }
  end
end
