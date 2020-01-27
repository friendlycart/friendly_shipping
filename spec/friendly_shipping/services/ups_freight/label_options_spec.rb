# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/label_options'

RSpec.describe FriendlyShipping::Services::UpsFreight::LabelOptions do
  subject do
    described_class.new(
      shipper_number: 'my_shipper_number',
      billing_address: double,
      shipping_method: double
    )
  end

  it { is_expected.to be_a(FriendlyShipping::Services::UpsFreight::RatesOptions) }
end
