# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsJson::AccessToken do
  subject(:access_token) do
    described_class.new(
      expires_in: 14_399,
      issued_at: 1_711_726_723_486,
      raw_token: "eyJraWQiOiI2NGM0YjYyMC0yZmFhLTQzNTYtYjA0"
    )
  end

  it { is_expected.to respond_to(:expires_in) }
  it { is_expected.to respond_to(:issued_at) }
  it { is_expected.to respond_to(:raw_token) }
end
