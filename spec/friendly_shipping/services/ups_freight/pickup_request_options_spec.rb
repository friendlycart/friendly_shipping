# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/pickup_request_options'

RSpec.describe FriendlyShipping::Services::UpsFreight::PickupRequestOptions do
  subject do
    described_class.new(
      requester: double,
      pickup_time_window: double,
      requester_email: double
    )
  end

  it { is_expected.to respond_to(:requester) }
  it { is_expected.to respond_to(:pickup_time_window) }
  it { is_expected.to respond_to(:comments) }
  it { is_expected.to respond_to(:requester_email) }
  it { is_expected.to respond_to(:third_party_requester) }
end
