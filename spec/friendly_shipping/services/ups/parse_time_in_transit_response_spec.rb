# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::ParseTimeInTransitResponse do
  include Dry::Monads[:result]
  let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ups', 'ups_timing_api_response.xml')) }
  let(:response) { double(body: response_body) }
  let(:request) { FriendlyShipping::Request.new(url: 'http://www.example.com') }

  subject(:result) do
    described_class.call(
      request: request,
      response: response,
    )
  end

  it { is_expected.to be_success }

  describe 'Success result value' do
    subject { result.value!.data }

    it 'returns rates along with the response' do
      expect(subject).to be_a(Enumerable)
      expect(subject.length).to eq(7)
      expect(subject.map(&:shipping_method).map(&:name)).to contain_exactly(
        "UPS Next Day Air Early",
        "UPS Next Day Air",
        "UPS Next Day Air Saver",
        "UPS 2nd Day Air A.M.",
        "UPS 2nd Day Air",
        "UPS Ground",
        "UPS 3 Day Select"
      )
      last_timing = subject.last
      expect(last_timing.shipping_method.name).to eq('UPS Ground')
      expect(last_timing.pickup.strftime('%Y-%m-%dT%H:%M')).to eq('2018-06-20T17:00')
      expect(last_timing.delivery.strftime('%Y-%m-%dT%H:%M')).to eq('2018-06-27T23:00')
      expect(subject.map { |h| h.data[:business_transit_days] }).to eq(["1", "1", "1", "2", "2", "3", "5"])
    end
  end

  context 'if pickup time is not given in the response' do
    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "ups", "ups_timing_without_pickup_time.xml")) }

    it { is_expected.to be_success }
  end
end
