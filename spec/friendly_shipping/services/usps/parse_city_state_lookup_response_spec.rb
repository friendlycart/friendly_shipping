# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps::ParseCityStateLookupResponse do
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'usps', 'zip_code_lookup_response.xml')).read }
  let(:request) { double }
  let(:response) { double(body: response_body) }
  let(:location) { Physical::Location.new(country: 'US') }

  subject { described_class.call(response: response, request: request, location: location) }

  it { is_expected.to be_success }

  it 'has correct data' do
    result_data = subject.value!.suggestions.first
    expect(result_data.city).to eq('WAKE FOREST')
    expect(result_data.region.code).to eq('NC')
  end
end
