# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/generate_pickup_options_hash'

RSpec.describe FriendlyShipping::Services::UpsFreight::GeneratePickupOptionsHash do
  subject { described_class.call(pickup_options: pickup_options) }

  let(:pickup_options) { FriendlyShipping::Services::UpsFreight::LabelPickupOptions.new }

  it { is_expected.to eq(nil) }

  context 'if lift gate is required' do
    let(:pickup_options) { FriendlyShipping::Services::UpsFreight::LabelPickupOptions.new(lift_gate_required: true) }

    it { is_expected.to eq(PickupOptions: { LiftGateRequiredIndicator: "" }) }
  end
end
