# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::RateEstimatesOptions do
  subject { described_class.new(carriers: [double(id: 'se-12345')]) }

  it { is_expected.to respond_to(:carriers) }
  it { is_expected.to be_a(FriendlyShipping::ShipmentOptions) }
end
