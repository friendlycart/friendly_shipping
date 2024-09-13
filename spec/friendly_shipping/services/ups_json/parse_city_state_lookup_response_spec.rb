# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsJson::ParseCityStateLookupResponse do
  subject(:call) { described_class.call(request:, response:) }

  let(:request) { FriendlyShipping::Request.new(url: "http://www.example.com", debug: true) }
  let(:response) { double(body: response_body, headers: {}) }
  let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "ups_json", "city_state_lookup.json")) }

  it 'returns location with city and state' do
    location = call.value!.data
    expect(location).to be_a(Physical::Location)
    expect(location.city).to eq("NEW YORK")
    expect(location.region).to eq(location.country.subregions.coded("NY"))
    expect(location.zip).to eq("10017")
    expect(location.country).to eq(Carmen::Country.coded("US"))
  end
end
