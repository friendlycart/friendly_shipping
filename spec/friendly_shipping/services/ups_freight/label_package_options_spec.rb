# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/label_package_options'

RSpec.describe FriendlyShipping::Services::UpsFreight::LabelPackageOptions do
  subject { described_class.new(package_id: nil) }

  it { is_expected.to be_a FriendlyShipping::Services::UpsFreight::RatesPackageOptions }
end
