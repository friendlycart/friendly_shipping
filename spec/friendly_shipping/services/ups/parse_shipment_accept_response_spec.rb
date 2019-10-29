# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups/parse_shipment_accept_response'

RSpec.describe FriendlyShipping::Services::Ups::ParseShipmentAcceptResponse do
  include Dry::Monads::Result::Mixin
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ups', 'shipment_accept_response.xml')).read }
  let(:response) { double(body: response_body) }
  let(:request) { FriendlyShipping::Request.new(url: 'http://www.example.com') }
  let(:shipment) { FactoryBot.build(:physical_shipment) }

  subject(:parser) { described_class.call(request: request, response: response) }

  it { is_expected.to be_a(Dry::Monads::Result) }

  it { is_expected.to be_success }

  describe 'result data' do
    subject { parser.value!.data }

    it 'returns labels along with the response' do
      expect(subject).to be_a(Array)
      expect(subject.length).to eq(1)
      expect(subject.map(&:tracking_number)).to be_present
      expect(subject.map(&:label_data).first.first(5)).to eq("GIF87")
      expect(subject.map(&:label_format).first.to_s).to eq("GIF")
      expect(subject.map(&:shipment_cost).first).to eq(11.98)
      expect(subject.map(&:data).first[:cost_breakdown]).to eq(
        "BaseServiceCharge" => 11.17.to_d,
        "ServiceOptionsCharges" => 0.0.to_d,
        "FUEL SURCHARGE" => 0.81.to_d
      )
    end
  end

  context "with a failed response" do
    let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ups', 'shipment_accept_failure.xml')).read }

    it 'returns a well-formed failure' do
      is_expected.to be_a(Dry::Monads::Result::Failure)
      expect(subject.failure.to_s).to eq("Failure: Missing or invalid shipment digest.")
    end
  end
end
