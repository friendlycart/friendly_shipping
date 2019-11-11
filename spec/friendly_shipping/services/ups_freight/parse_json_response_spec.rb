# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/parse_json_response'

RSpec.describe FriendlyShipping::Services::UpsFreight::ParseJSONResponse do
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ups_freight', 'rate_estimates', 'failure.json')).read }

  subject(:parser) { described_class.call(response_body, 'FreightRateResponse') }

  it { is_expected.to be_failure }

  it 'has the correct error message' do
    expect(subject.failure.to_s).to eq('9360256: Missing Commodity.')
  end

  context 'with invalid JSON in response body' do
    let(:response_body) { 'invalid JSON' }

    it { is_expected.to be_failure }

    it 'has the correct error' do
      expect(subject.failure).to be_a(JSON::ParserError)
      expect(subject.failure.message).to match(/unexpected token/)
    end
  end

  context 'with a successful response' do
    let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ups_freight', 'rate_estimates', 'success.json')).read }

    it { is_expected.to be_success }

    it 'contains a Hash' do
      expect(subject.value!).to match(hash_including("FreightRateResponse"))
    end
  end
end
