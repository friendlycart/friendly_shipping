# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngineLTL::ParseQuoteResponse do
  subject { described_class.call(request: request, response: response) }

  let(:response) { double(body: response_body) }
  let(:request) { double(debug: false) }

  context 'with successful response' do
    let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ship_engine_ltl', 'quotes.json')).read }
    let(:api_result) { subject.value! }
    let(:rate) { api_result.data.first }

    it 'returns an Array of rates' do
      expect(subject).to be_success
      expect(api_result.data).to be_a Array
      expect(rate).to be_a FriendlyShipping::Rate
    end

    it 'contains correct data' do
      expect(rate.shipping_method.name).to eq('Standard')
      expect(rate.shipping_method.service_code).to eq('stnd')
      expect(rate.amounts).to eq(total: Money.new(307, 'USD'))
      expect(rate.warnings).to be_empty
      expect(rate.errors).to be_empty
      expect(rate.data).to eq({})
    end
  end

  context 'with unsuccessful response' do
    let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ship_engine_ltl', 'not_authorized.json')).read }
    let(:api_result) { subject.failure }

    it 'returns error message' do
      expect(subject).to be_failure
      expect(api_result.data).to eq(['Not authorized.'])
    end
  end
end
