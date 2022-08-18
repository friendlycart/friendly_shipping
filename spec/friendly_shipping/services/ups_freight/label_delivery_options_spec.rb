# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/label_delivery_options'

RSpec.describe FriendlyShipping::Services::UpsFreight::LabelDeliveryOptions do
  subject { described_class.new }

  it { is_expected.to respond_to(:call_before_delivery) }
  it { is_expected.to respond_to(:holiday_delivery) }
  it { is_expected.to respond_to(:inside_delivery) }
  it { is_expected.to respond_to(:residential_delivery) }
  it { is_expected.to respond_to(:weekend_delivery) }
  it { is_expected.to respond_to(:lift_gate_required) }
  it { is_expected.to respond_to(:limited_access_delivery) }
end
