# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/rl/item_options'

RSpec.describe FriendlyShipping::Services::RL::ItemOptions do
  subject(:options) { described_class.new(item_id: "123") }

  it { is_expected.to respond_to(:freight_class) }
end
