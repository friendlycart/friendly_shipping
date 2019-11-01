# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups/serialize_shipment_accept_request'

RSpec.describe FriendlyShipping::Services::Ups::SerializeShipmentAcceptRequest do
  let(:options) do
    FriendlyShipping::Services::Ups::LabelOptions.new(
      shipping_method: double,
      shipper_number: '12345',
      customer_context: 'my_request_id'
    )
  end
  let(:xml) { described_class.call(digest: 'supers3cret', options: options) }

  describe '.call' do
    subject { Nokogiri::XML(xml) }

    it 'has the right data in the right places' do
      expect(subject.at_xpath('//ShipmentAcceptRequest')).to be_present
      expect(subject.at_xpath('//ShipmentAcceptRequest/Request/RequestAction').text).to eq('ShipAccept')
      expect(subject.at_xpath('//ShipmentAcceptRequest/Request/SubVersion').text).to eq('1707')
      expect(subject.at_xpath('//ShipmentAcceptRequest/Request/TransactionReference/CustomerContext').text).to eq('my_request_id')
      expect(subject.at_xpath('//ShipmentAcceptRequest/ShipmentDigest').text).to eq('supers3cret')
    end
  end
end
