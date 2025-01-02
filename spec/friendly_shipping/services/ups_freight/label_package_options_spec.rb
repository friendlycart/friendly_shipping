# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::LabelPackageOptions do
  subject { described_class.new(package_id: nil) }

  it { is_expected.to be_a FriendlyShipping::Services::UpsFreight::RatesPackageOptions }
end
