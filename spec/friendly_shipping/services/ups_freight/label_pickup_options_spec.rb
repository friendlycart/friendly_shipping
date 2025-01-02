# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::LabelPickupOptions do
  subject { described_class.new }

  it { is_expected.to respond_to(:holiday_pickup) }
  it { is_expected.to respond_to(:inside_pickup) }
  it { is_expected.to respond_to(:residential_pickup) }
  it { is_expected.to respond_to(:weekend_pickup) }
  it { is_expected.to respond_to(:lift_gate_required) }
  it { is_expected.to respond_to(:limited_access_pickup) }
end
