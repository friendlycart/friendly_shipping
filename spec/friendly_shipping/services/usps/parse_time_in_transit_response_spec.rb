# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/usps/parse_time_in_transit_response'

RSpec.describe FriendlyShipping::Services::Usps::ParseTimeInTransitResponse do
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'usps', 'time_in_transit_response.xml')).read }
  let(:response) { double(body: response_body) }
  let(:request) { FriendlyShipping::Request.new(url: 'http://www.example.com') }

  subject(:result) do
    described_class.call(response: response, request: request)
  end

  it { is_expected.to be_success }

  describe 'success value' do
    subject { result.value!.data }

    it 'parses response' do
      expect(subject).to be_a(Enumerable)
      expect(subject.length).to eq(11)
      first_rate = subject.first
      expect(first_rate.shipping_method.name).to eq('Priority Mail Express')
      expect(first_rate.pickup).to eq(Time.new(2019, 12, 0o3))
      expect(first_rate.delivery).to eq(Time.new(2019, 12, 0o4))
      expect(first_rate.properties).to eq(
        commitment: '1-Day'
      )
      last_rate = subject.last
      expect(last_rate.shipping_method.name).to eq('First-Class Package Service')
      expect(last_rate.pickup).to eq(Time.new(2019, 12, 0o3))
      expect(last_rate.delivery).to eq(Time.new(2019, 12, 0o5))
      expect(last_rate.properties).to eq(
        commitment: '2 Days',
        destination_type: :hold_for_pickup
      )
    end

    context 'if there are no expedited nodes' do
      let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'usps', 'time_in_transit_response_without_expedited.xml')).read }

      it "does not break" do
        last_rate = subject.last
        expect(last_rate.shipping_method.name).to eq('First-Class Package Service')
        expect(last_rate.pickup).to eq(Time.new(2019, 12, 0o3))
        expect(last_rate.delivery).to eq(Time.new(2019, 12, 0o5))
        expect(last_rate.properties).to eq(
          commitment: '2 Days',
          destination_type: :hold_for_pickup
        )
      end
    end

    context 'if there is an invalid commitment sequence' do
      let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'usps', 'time_in_transit_response_with_invalid_commitment_seq.xml')).read }

      it "does not break" do
        first_rate = subject.first
        expect(first_rate.shipping_method.name).to eq('Priority')
        expect(first_rate.pickup).to eq(Time.new(2020, 1, 17))
        expect(first_rate.delivery).to eq(Time.new(2020, 1, 19))
        expect(first_rate.properties).to eq(
          commitment: '2-Day',
          destination_type: :street
        )
      end
    end
  end
end
