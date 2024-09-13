# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsJson::GenerateCityStateLookupPayload do
  subject(:call) { described_class.call(location:) }

  let(:location) { FactoryBot.build(:physical_location, zip: "12345") }

  it 'returns a hash with the required fields' do
    xav_request = call[:XAVRequest]
    expect(xav_request[:RegionalRequestIndicator]).to eq("1")
    expect(xav_request[:AddressKeyFormat]).to be_a(Array)
    expect(xav_request[:AddressKeyFormat].size).to eq(1)
    expect(xav_request[:AddressKeyFormat].first[:PostcodePrimaryLow]).to eq("12345")
    expect(xav_request[:AddressKeyFormat].first[:CountryCode]).to eq("US")
  end
end
