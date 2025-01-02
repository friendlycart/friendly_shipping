# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::LabelItemOptions do
  subject { described_class.new(item_id: nil) }

  it { is_expected.to be_a FriendlyShipping::Services::UpsFreight::RatesItemOptions }
end
