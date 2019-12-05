# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/usps/serialize_time_in_transit_request'
require 'friendly_shipping/services/usps/timing_options'

RSpec.describe FriendlyShipping::Services::Usps::SerializeTimeInTransitRequest do
  let(:pickup_date) { Time.parse('2017-01-01 00:15:00 UTC') }

  let(:shipment) do
    Physical::Shipment.new(
      origin: Physical::Location.new(zip: '12345'),
      destination: Physical::Location.new(zip: '67890')
    )
  end

  let(:timing_options) do
    FriendlyShipping::Services::Usps::TimingOptions.new(
      pickup: pickup_date
    )
  end

  subject { described_class.call(shipment: shipment, options: timing_options, login: 'login') }

  it 'serializes request' do
    doc = Nokogiri::XML::Document.parse(subject)
    node = doc.xpath('//SDCGetLocationsRequest')
    expect(node.attr('USERID').value).to eq('login')
    expect(node.at_xpath('MailClass').text).to eq('0')
    expect(node.at_xpath('OriginZIP').text).to eq('12345')
    expect(node.at_xpath('DestinationZIP').text).to eq('67890')
    expect(node.at_xpath('AcceptDate').text).to eq('01-Jan-2017')
    expect(node.at_xpath('NonEMDetail').text).to eq('true')
  end
end
