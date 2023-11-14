# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::ParseCityStateLookupResponse do
  let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ups', 'city_state_lookup_response.xml')) }
  let(:request) { double(debug: false) }
  let(:response) { double(body: response_body) }
  let(:location) { Physical::Location.new(country: 'US') }

  subject { described_class.call(response: response, request: request, location: location) }

  it { is_expected.to be_success }

  it 'has correct data' do
    result_data = subject.value!.data.first
    expect(result_data.city).to eq('WAKE FOREST')
    expect(result_data.region.code).to eq('NC')
  end
end
