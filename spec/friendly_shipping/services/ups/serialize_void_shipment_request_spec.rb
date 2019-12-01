# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups/serialize_void_shipment_request'

RSpec.describe FriendlyShipping::Services::Ups::SerializeVoidShipmentRequest do
  let(:label) { FriendlyShipping::Label.new(tracking_number: '1ZTRACKING') }
  let(:serialized_data) { described_class.call(label: label) }

  describe '#to_xml' do
    subject { Nokogiri::XML(serialized_data) }

    it 'has the right data in the right places' do
      expect(subject.at_xpath('//VoidShipmentRequest')).to be_present
      expect(subject.at_xpath('//VoidShipmentRequest/Request/RequestAction').text).to eq('Void')
      expect(subject.at_xpath('//VoidShipmentRequest/ShipmentIdentificationNumber').text).to eq('1ZTRACKING')
    end
  end
end
