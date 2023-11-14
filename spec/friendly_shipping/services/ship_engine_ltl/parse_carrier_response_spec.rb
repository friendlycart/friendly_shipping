# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngineLTL::ParseCarrierResponse do
  subject { described_class.call(request: request, response: response) }

  let(:response) { double(body: response_body) }
  let(:request) { double(debug: false) }

  context 'with successful response' do
    let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ship_engine_ltl', 'carriers.json')) }
    let(:api_result) { subject.value! }
    let(:carrier) { api_result.data.first }

    it 'returns an Array of carriers' do
      expect(subject).to be_success
      expect(api_result.data).to be_a Array
      expect(carrier).to be_a FriendlyShipping::Carrier
    end

    it 'contains correct data in the carrier' do
      expect(carrier.id).to eq('1fd96e9e-9a25-436a-8e11-c6e4500cb7de')
      expect(carrier.name).to eq('UPS Freight')
      expect(carrier.data[:countries]).to eq(%w[CA MX US])
      expect(carrier.data[:features]).to eq(%w[auto_pro connect documents quote scheduled_pickup spot_quote tracking])
      expect(carrier.data[:scac]).to eq('UPGF')
    end
  end

  context 'with unsuccessful response' do
    let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ship_engine_ltl', 'not_authorized.json')) }
    let(:api_result) { subject.failure }

    it 'returns error message' do
      expect(subject).to be_failure
      expect(api_result.data).to eq(['Not authorized.'])
    end
  end
end
