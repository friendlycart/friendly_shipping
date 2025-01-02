# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::GenerateDeliveryOptionsHash do
  subject { described_class.call(delivery_options: delivery_options) }

  let(:delivery_options) { FriendlyShipping::Services::UpsFreight::LabelDeliveryOptions.new }

  it { is_expected.to eq(nil) }

  context 'if lift gate is required' do
    let(:delivery_options) { FriendlyShipping::Services::UpsFreight::LabelDeliveryOptions.new(lift_gate_required: true) }

    it { is_expected.to eq(DeliveryOptions: { LiftGateRequiredIndicator: "" }) }
  end
end
