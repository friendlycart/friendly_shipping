# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups/serialize_time_in_transit_request'
require 'friendly_shipping/services/ups/timing_options'

RSpec.describe FriendlyShipping::Services::Ups::SerializeTimeInTransitRequest do
  let(:origin) do
    Physical::Location.new(
      country: 'US',
      region: 'NC',
      city: 'Durham',
      zip: '27703'
    )
  end
  let(:destination) do
    Physical::Location.new(
      country: 'US',
      region: 'FL',
      zip: '32821'
    )
  end

  let(:package) do
    Physical::Package.new(
      weight: Measured::Weight.new(5, :pounds),
    )
  end

  let(:shipment) do
    Physical::Shipment.new(
      origin: origin,
      destination: destination,
      packages: [package]
    )
  end

  let(:options) do
    FriendlyShipping::Services::Ups::TimingOptions.new(
      pickup: Time.new(2018, 9, 15, 10, 0, 0),
      customer_context: 'Time in Transit'
    )
  end

  subject do
    Nokogiri::XML(
      described_class.call(
        shipment: shipment,
        options: options
      )
    )
  end

  it 'contains the right data' do
    aggregate_failures do
      node = subject.at_xpath('//TimeInTransitRequest')
      expect(node.at_xpath('Request/TransactionReference/CustomerContext').text).to eq('Time in Transit')
      expect(node.at_xpath('Request/RequestAction').text).to eq('TimeInTransit')

      expect(node.at_xpath('TransitFrom/AddressArtifactFormat/PoliticalDivision2').text).to eq('Durham')
      expect(node.at_xpath('TransitFrom/AddressArtifactFormat/PoliticalDivision1').text).to eq('NC')
      expect(node.at_xpath('TransitFrom/AddressArtifactFormat/CountryCode').text).to eq('US')
      expect(node.at_xpath('TransitFrom/AddressArtifactFormat/PostcodePrimaryLow').text).to eq('27703')

      expect(node.at_xpath('TransitTo/AddressArtifactFormat/PostcodePrimaryLow').text).to eq('32821')

      expect(node.at_xpath('ShipmentWeight/UnitOfMeasurement/Code').text).to eq('LBS')
      expect(node.at_xpath('ShipmentWeight/Weight').text).to eq('5.0')
    end
  end
end
