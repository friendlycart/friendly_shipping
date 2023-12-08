# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/tforce_freight/rates_package_options'

RSpec.describe FriendlyShipping::Services::TForceFreight::RatesPackageOptions do
  subject(:rates_package_options) { described_class.new(package_id: nil) }

  describe 'item options' do
    subject(:item_options) { rates_package_options.options_for_item(item) }

    let(:item) { double(item_id: nil) }

    it { is_expected.to be_a(FriendlyShipping::Services::TForceFreight::RatesItemOptions) }
  end
end
