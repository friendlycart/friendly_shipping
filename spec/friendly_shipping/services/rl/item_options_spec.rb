# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::ItemOptions do
  subject(:options) do
    described_class.new(
      item_id: "123",
      freight_class: "92.5"
    )
  end

  it { is_expected.to respond_to(:freight_class) }
end
