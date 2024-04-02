# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip::AccessToken do
  subject(:access_token) do
    described_class.new(
      token_type: "Bearer",
      expires_in: 3599,
      raw_token: "XYADfw4Hz2KdN_sd8N4TzMo9"
    )
  end

  it { is_expected.to respond_to(:token_type) }
  it { is_expected.to respond_to(:expires_in) }
  it { is_expected.to respond_to(:raw_token) }

  describe "#decoded_token" do
    subject(:decoded_token) { access_token.decoded_token }

    before do
      expect(JWT).to receive(:decode).with("XYADfw4Hz2KdN_sd8N4TzMo9", nil, false).and_return("result")
    end

    it { is_expected.to eq("result") }
  end
end
