# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups/parse_shipment_confirm_response'

RSpec.describe FriendlyShipping::Services::Ups::ParseShipmentConfirmResponse do
  include Dry::Monads::Result::Mixin
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ups', 'shipment_confirm_response.xml')).read }
  let(:response) { double(body: response_body) }
  let(:request) { FriendlyShipping::Request.new(url: 'http://www.example.com') }
  let(:shipment) { FactoryBot.build(:physical_shipment) }

  subject(:parser) { described_class.call(request: request, response: response) }

  it { is_expected.to be_a(Dry::Monads::Result) }

  it { is_expected.to be_success }

  describe '#data' do
    subject { parser.value!.data }

    it { is_expected.to eq('very-long-digest-number') }
  end

  context "if the request fails" do
    let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ups', 'shipment_confirm_failure.xml')).read }

    it { is_expected.to be_a(Dry::Monads::Result) }

    it "can be serialized to a nice error string" do
      expect(subject.failure.to_s).to eq("Failure: Invalid ShipTo AddressLine2")
    end
  end
end
