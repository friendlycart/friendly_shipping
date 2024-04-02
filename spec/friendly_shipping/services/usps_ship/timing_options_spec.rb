# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip::TimingOptions do
  it { expect(described_class).to eq(FriendlyShipping::Services::USPSShip::RateEstimateOptions) }
end
