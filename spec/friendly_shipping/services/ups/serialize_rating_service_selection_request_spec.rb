# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::SerializeRatingServiceSelectionRequest do
  let(:origin) { FactoryBot.build(:physical_location) }

  let(:destination) { FactoryBot.build(:physical_location )}

  let(:dimensions) do
    [
      Measured::Length.new(10, :centimeters),
      Measured::Length.new(10, :centimeters),
      Measured::Length.new(10, :centimeters),
    ]
  end
  let(:package) do
    Physical::Package.new(
      container: Physical::Box.new(
        weight: Measured::Weight.new(5, :pounds),
        dimensions: dimensions
      )
    )
  end

  let(:shipment) do
    Physical::Shipment.new(
      origin: origin,
      destination: destination,
      packages: [package],
      options: options
    )
  end

  let(:options) { {origin_account: "12345"} }

  subject do
    Nokogiri::XML(
      described_class.call(shipment: shipment)
    )
  end

  it 'contains the right data' do
    aggregate_failures do
      expect(subject.at_xpath('//RatingServiceSelectionRequest')).to be_present
      expect(subject.at_xpath('//RatingServiceSelectionRequest/Request')).to be_present
      expect(subject.at_xpath('//RatingServiceSelectionRequest/Request/RequestAction').text).to eq('Rate')
      expect(subject.at_xpath('//RatingServiceSelectionRequest/Request/RequestOption').text).to eq('Shop')
      expect(subject.at_xpath('//RatingServiceSelectionRequest/Request/SubVersion').text).to eq('1707')
      expect(subject.at_xpath('//RatingServiceSelectionRequest/PickupType/Code').text).to eq('01')
      expect(subject.at_xpath('//RatingServiceSelectionRequest/CustomerClassification/Code').text).to eq('01')
      expect(
        subject.at_xpath('//RatingServiceSelectionRequest/Shipment/Shipper/Address/AddressLine1').text
      ).to eq('11 Lovely Street')
      expect(subject.at_xpath('//RatingServiceSelectionRequest/Shipment/Shipper/ShipperNumber').text).to be_present
      expect(
        subject.at_xpath('//RatingServiceSelectionRequest/Shipment/ShipTo/ShipperAssignedIdentificationNumber')
      ).not_to be_present
      expect(subject.at_xpath('//RatingServiceSelectionRequest/Shipment/ShipFrom')).not_to be_present
      expect(subject.at_xpath('//RatingServiceSelectionRequest/Shipment/Package')).to be_present
      expect(subject.at_xpath('//RatingServiceSelectionRequest/Shipment/Package/PackagingType/Code').text).to eq('02')
      expect(
        subject.at_xpath('//RatingServiceSelectionRequest/Shipment/Package/PackageWeight/UnitOfMeasurement/Code').text
      ).to eq('LBS')
      expect(subject.at_xpath('//RatingServiceSelectionRequest/Shipment/Package/PackageWeight/Weight').text).to eq('5')
    end
  end

  context 'with a different shipper' do
    let(:options) { {shipper: FactoryBot.build(:physical_location, address1: "Another Street")} }

    it 'contains an extra ShipFrom element' do
      aggregate_failures do
        expect(subject.at_xpath('//RatingServiceSelectionRequest/Shipment/ShipFrom')).to be_present
        expect(
          subject.at_xpath('//RatingServiceSelectionRequest/Shipment/Shipper/Address/AddressLine1').text
        ).to eq('Another Street')
        expect(
          subject.at_xpath('//RatingServiceSelectionRequest/Shipment/ShipFrom/Address/AddressLine1').text
        ).to eq('11 Lovely Street')
      end
    end
  end
end
