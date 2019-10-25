# frozen_string_literal: true

RSpec.describe FriendlyShipping::Services::ShipEngine::RateEstimatesOptions do
  it { is_expected.to respond_to(:carriers) }
end
