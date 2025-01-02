# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::ParseShipmentAcceptResponse do
  include Dry::Monads[:result]
  let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ups', 'shipment_accept_response.xml')) }
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
      expect(subject.map(&:usps_tracking_number).compact).to be_empty
      expect(subject.map(&:label_data).first.first(5)).to eq("GIF87")
      expect(subject.map(&:label_format).first.to_s).to eq("GIF")
      expect(subject.map(&:shipment_cost).first.to_d).to eq(11.98)
      expect(subject.map(&:data).first[:cost_breakdown]).to eq(
        "BaseServiceCharge" => Money.new(1117, 'USD'),
        "FUEL SURCHARGE" => Money.new(81, 'USD')
      )
    end
  end

  context "with a failed response" do
    let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ups', 'shipment_accept_failure.xml')) }

    it 'returns a well-formed failure' do
      is_expected.to be_a(Dry::Monads::Result::Failure)
      expect(subject.failure.to_s).to eq("Failure: Missing or invalid shipment digest.")
    end
  end

  context "with a response with paperless invoice" do
    let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ups', 'shipment_accept_international.xml')) }

    it { is_expected.to be_success }

    it 'contains document data' do
      expect(subject.value!.data.first.data[:form_format]).to eq("PDF")
      expect(subject.value!.data.first.data[:form]).to start_with('%PDF-')
    end
  end

  context "SurePost" do
    let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ups', 'surepost_shipment_accept_response.xml')) }
    subject { parser.value!.data }

    it 'returns labels including value for usps_tracking_number' do
      expect(subject).to be_a(Array)
      expect(subject.map(&:tracking_number)).to be_present
      expect(subject.map(&:usps_tracking_number)).to be_present
    end
  end
end
