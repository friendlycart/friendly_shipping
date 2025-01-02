# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::SerializeRatingServiceSelectionRequest do
  let(:origin) { FactoryBot.build(:physical_location) }

  let(:destination) { FactoryBot.build(:physical_location ) }

  let(:dimensions) do
    [
      Measured::Length.new(10, :centimeters),
      Measured::Length.new(10, :centimeters),
      Measured::Length.new(10, :centimeters),
    ]
  end
  let(:package) do
    Physical::Package.new(
      id: "my_id_one",
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
      packages: [package]
    )
  end

  let(:options) do
    FriendlyShipping::Services::Ups::RateEstimateOptions.new(
      sub_version: "2205",
      shipper_number: "12345"
    )
  end

  subject(:xml) do
    Nokogiri::XML(
      described_class.call(shipment: shipment, options: options)
    )
  end

  it 'contains the right data' do
    aggregate_failures do
      expect(xml.at_xpath('//RatingServiceSelectionRequest')).to be_present
      expect(xml.at_xpath('//RatingServiceSelectionRequest/Request')).to be_present
      expect(xml.at_xpath('//RatingServiceSelectionRequest/Request/RequestAction').text).to eq('Rate')
      expect(xml.at_xpath('//RatingServiceSelectionRequest/Request/RequestOption').text).to eq('Shop')
      expect(xml.at_xpath('//RatingServiceSelectionRequest/Request/SubVersion').text).to eq('2205')
      expect(xml.at_xpath('//RatingServiceSelectionRequest/PickupType/Code').text).to eq('01')
      expect(xml.at_xpath('//RatingServiceSelectionRequest/CustomerClassification/Code').text).to eq('01')
      expect(
        xml.at_xpath('//RatingServiceSelectionRequest/Shipment/Shipper/Address/AddressLine1').text
      ).to eq('11 Lovely Street')
      expect(xml.at_xpath('//RatingServiceSelectionRequest/Shipment/Shipper/ShipperNumber').text).to be_present
      expect(
        xml.at_xpath('//RatingServiceSelectionRequest/Shipment/ShipTo/ShipperAssignedIdentificationNumber')
      ).not_to be_present
      expect(xml.at_xpath('//RatingServiceSelectionRequest/Shipment/ShipFrom')).not_to be_present
      expect(xml.at_xpath('//RatingServiceSelectionRequest/Shipment/Package')).to be_present
      expect(xml.at_xpath('//RatingServiceSelectionRequest/Shipment/Package/Dimensions')).to be_present

      expect(xml.at_xpath('//RatingServiceSelectionRequest/Shipment/Package/PackagingType/Code').text).to eq('02')
      expect(
        xml.at_xpath('//RatingServiceSelectionRequest/Shipment/Package/PackageWeight/UnitOfMeasurement/Code').text
      ).to eq('LBS')
      expect(xml.at_xpath('//RatingServiceSelectionRequest/Shipment/Package/PackageWeight/Weight').text).to eq('5')
    end
  end

  context 'with a different shipper' do
    let(:options) do
      FriendlyShipping::Services::Ups::RateEstimateOptions.new(
        shipper_number: "12345",
        shipper: FactoryBot.build(:physical_location, address1: "Another Street")
      )
    end

    it 'contains an extra ShipFrom element' do
      aggregate_failures do
        expect(xml.at_xpath('//RatingServiceSelectionRequest/Shipment/ShipFrom')).to be_present
        expect(
          xml.at_xpath('//RatingServiceSelectionRequest/Shipment/Shipper/Address/AddressLine1').text
        ).to eq('Another Street')
        expect(
          xml.at_xpath('//RatingServiceSelectionRequest/Shipment/ShipFrom/Address/AddressLine1').text
        ).to eq('11 Lovely Street')
      end
    end
  end

  context 'with a destination account' do
    let(:options) do
      FriendlyShipping::Services::Ups::RateEstimateOptions.new(
        shipper_number: "12345",
        destination_account: '98765'
      )
    end

    it 'contains a ShipperAssignedIdentificationNumber element' do
      expect(
        xml.at_xpath('//RatingServiceSelectionRequest/Shipment/ShipTo/ShipperAssignedIdentificationNumber').text
      ).to eq('98765')
    end
  end

  context 'with carbon_neutral set to true' do
    let(:options) do
      FriendlyShipping::Services::Ups::RateEstimateOptions.new(
        shipper_number: "12345",
        carbon_neutral: true
      )
    end

    it 'contains a UPScarbonneutralIndicator element' do
      expect(
        xml.at_xpath('/RatingServiceSelectionRequest/Shipment/ShipmentServiceOptions/UPScarbonneutralIndicator')
      ).to be_present
    end
  end

  context 'with a customer context given' do
    let(:options) do
      FriendlyShipping::Services::Ups::RateEstimateOptions.new(
        shipper_number: "12345",
        customer_context: 'MYORDER!!'
      )
    end

    it 'contains a CustomerContext element' do
      expect(
        xml.at_xpath('/RatingServiceSelectionRequest/Request/TransactionReference/CustomerContext').text
      ).to eq('MYORDER!!')
    end
  end

  context 'with a special customer classification given' do
    let(:options) do
      FriendlyShipping::Services::Ups::RateEstimateOptions.new(
        shipper_number: "12345",
        customer_classification: :regional_rates
      )
    end

    it 'contains the right option' do
      expect(
        xml.at_xpath('/RatingServiceSelectionRequest/CustomerClassification/Code').text
      ).to eq('05')
    end
  end

  context 'with negotiated rates set to true' do
    let(:options) do
      FriendlyShipping::Services::Ups::RateEstimateOptions.new(
        shipper_number: "12345",
        negotiated_rates: true
      )
    end

    it 'contains the right option' do
      expect(
        xml.at_xpath('/RatingServiceSelectionRequest/Shipment/RateInformation/NegotiatedRatesIndicator')
      ).to be_present
    end
  end

  context 'with saturday delivery requested' do
    let(:options) do
      FriendlyShipping::Services::Ups::RateEstimateOptions.new(
        shipper_number: "12345",
        saturday_delivery: true
      )
    end

    it 'contains the right option' do
      expect(
        xml.at_xpath('/RatingServiceSelectionRequest/Shipment/ShipmentServiceOptions/SaturdayDelivery')
      ).to be_present
    end
  end

  context 'with saturday pickup requested' do
    let(:options) do
      FriendlyShipping::Services::Ups::RateEstimateOptions.new(
        shipper_number: "12345",
        saturday_pickup: true
      )
    end

    it 'contains the right option' do
      expect(
        xml.at_xpath('/RatingServiceSelectionRequest/Shipment/ShipmentServiceOptions/SaturdayPickup')
      ).to be_present
    end
  end

  context 'with a shipping method requested' do
    let(:options) do
      FriendlyShipping::Services::Ups::RateEstimateOptions.new(
        shipper_number: "12345",
        shipping_method: FriendlyShipping::ShippingMethod.new(service_code: 44)
      )
    end

    it 'contains the right option' do
      expect(xml.at_xpath('/RatingServiceSelectionRequest/Request/RequestOption')).not_to be_present
      expect(
        xml.at_xpath('/RatingServiceSelectionRequest/Shipment/Service/Code').text
      ).to eq('44')
    end
  end

  context 'when `transmit_dimensions` is set to false' do
    let(:options) do
      FriendlyShipping::Services::Ups::RateEstimateOptions.new(
        shipper_number: "12345",
        package_options: [
          FriendlyShipping::Services::Ups::RateEstimatePackageOptions.new(
            package_id: package.id,
            transmit_dimensions: false
          )
        ]
      )
    end

    it 'does not transmit dimensions' do
      expect(xml.at_xpath('//RatingServiceSelectionRequest/Shipment/Package/Dimensions')).not_to be_present
    end
  end

  context 'with a pickup date' do
    let(:options) do
      FriendlyShipping::Services::Ups::RateEstimateOptions.new(
        sub_version: '2205',
        shipper_number: '12345',
        pickup_date: Time.parse('2023-11-13 16:00:00 UTC')
      )
    end

    it 'contains the right data' do
      pickup = xml.xpath('//RatingServiceSelectionRequest/Shipment/DeliveryTimeInformation/Pickup')
      expect(pickup.at_xpath('Date').text).to eq('20231113')
      expect(pickup.at_xpath('Time').text).to eq('1600')
    end
  end
end
