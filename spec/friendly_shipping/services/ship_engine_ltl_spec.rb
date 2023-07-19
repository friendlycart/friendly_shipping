# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngineLTL do
  subject(:service) { described_class.new(token: ENV['SHIPENGINE_API_KEY']) }

  let(:carrier_id) { ENV['SHIPENGINE_LTL_CARRIER_ID'] }
  let(:scac) { ENV['SHIPENGINE_LTL_CARRIER_SCAC'] }

  it { is_expected.to respond_to(:carriers) }

  describe 'initialization' do
    it { is_expected.not_to respond_to :token }
  end

  describe '#carriers' do
    subject { service.carriers }

    context 'with a successful request', vcr: { cassette_name: 'shipengine_ltl/carriers/success' } do
      it { is_expected.to be_a Dry::Monads::Success }
      it { expect(subject.value!.data[0]).to be_a FriendlyShipping::Carrier }
      it { expect(subject.value!.data[0].id).to eq('1fd96e9e-9a25-436a-8e11-c6e4500cb7de') }
      it { expect(subject.value!.data[0].name).to eq('UPS Freight') }
      it { expect(subject.value!.data[0].data).to eq({ countries: %w[CA MX US], features: %w[auto_pro connect documents quote scheduled_pickup spot_quote tracking], scac: scac }) }
    end

    context 'with an unsuccessful request', vcr: { cassette_name: 'shipengine_ltl/carriers/failure' } do
      let(:service) { described_class.new(token: 'invalid_token') }

      it { is_expected.to be_a Dry::Monads::Failure }
      it { expect(subject.failure.data).to be_a RestClient::Unauthorized }
    end
  end

  describe '#connect_carrier' do
    let(:credentials) do
      {
        username: ENV['UPS_LOGIN'],
        password: ENV['UPS_PASSWORD'],
        key: ENV['UPS_KEY'],
        account_number: ENV['UPS_SHIPPER_NUMBER']
      }
    end

    subject { service.connect_carrier(credentials, scac) }

    context 'with a successful request', vcr: { cassette_name: 'shipengine_ltl/connect_carrier/success' } do
      it { is_expected.to be_a Dry::Monads::Success }
      it { expect(subject.value!.data).to eq({ 'carrier_id' => carrier_id }) }
    end

    context 'with an unsuccessful request', vcr: { cassette_name: 'shipengine_ltl/connect_carrier/failure' } do
      let(:scac) { 'bogus' }

      it { is_expected.to be_a Dry::Monads::Failure }
      it { expect(subject.failure.data).to be_a FriendlyShipping::Services::ShipEngine::BadRequest }
      it { expect(subject.failure.data.message).to eq('Invalid carrier SCAC') }
    end
  end

  describe '#update_carrier' do
    let(:credentials) do
      {
        username: ENV['UPS_LOGIN'],
        password: ENV['UPS_PASSWORD'],
        key: ENV['UPS_KEY'],
        account_number: ENV['UPS_SHIPPER_NUMBER']
      }
    end

    subject { service.update_carrier(credentials, scac, carrier_id) }

    context 'with a successful request', vcr: { cassette_name: 'shipengine_ltl/update_carrier/success' } do
      it { is_expected.to be_a Dry::Monads::Success }
      it { expect(subject.value!.data).to eq({ 'carrier_id' => carrier_id }) }
    end

    context 'with an unsuccessful request', vcr: { cassette_name: 'shipengine_ltl/update_carrier/failure' } do
      let(:carrier_id) { 'bogus' }

      it { is_expected.to be_a Dry::Monads::Failure }
      it { expect(subject.failure.data).to be_a RestClient::Unauthorized }
    end
  end
end
