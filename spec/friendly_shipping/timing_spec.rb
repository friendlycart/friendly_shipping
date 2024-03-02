# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/timing'

RSpec.describe FriendlyShipping::Timing do
  subject do
    described_class.new(
      shipping_method: FriendlyShipping::ShippingMethod.new,
      pickup: Time.now,
      delivery: Time.now + 2.days
    )
  end

  it { is_expected.to respond_to(:shipping_method) }
  it { is_expected.to respond_to(:pickup) }
  it { is_expected.to respond_to(:delivery) }
  it { is_expected.to respond_to(:guaranteed) }
  it { is_expected.to respond_to(:warnings) }
  it { is_expected.to respond_to(:errors) }
  it { is_expected.to respond_to(:properties) }
end
