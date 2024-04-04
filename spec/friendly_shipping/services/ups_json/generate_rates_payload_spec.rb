# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsJson::GenerateRatesPayload do
  subject(:call) {
    described_class.call(
      shipment: shipment,
      options: options
    )
  }

  let(:shipment) { FactoryBot.build(:physical_shipment, origin: origin, destination: destination, service_code: nil) }
  let(:options) { FriendlyShipping::Services::UpsJson::RatesOptions.new(shipper_number: "123456") }
  let(:origin) { FactoryBot.build(:physical_location, company_name: "A very nice company", address1: "2 Main St", address2: nil, zip: "00001") }
  let(:destination) { FactoryBot.build(:physical_location, name: "Homer Candler", zip: "90002") }

  it 'returns a hash with the required fields' do
    expect(subject[:RateRequest][:PickupType][:Code]).to eq("01")
    expect(subject[:RateRequest][:CustomerClassification][:Code]).to eq("01")
    expect(subject[:RateRequest][:Shipment][:Shipper][:Address][:AddressLine]).to eq(["2 Main St"])
    expect(subject[:RateRequest][:Shipment][:ShipTo][:Address][:AddressLine]).to eq(["11 Lovely Street", "Suite 100"])
    expect(subject[:RateRequest][:Shipment][:ShipFrom][:Address][:AddressLine]).to eq(["2 Main St"])
    expect(subject[:RateRequest][:Shipment][:PaymentDetails][:ShipmentCharge]).to eq([{ BillShipper: { AccountNumber: "123456" }, Type: "01" }])
  end

  context "with additional options" do
    context "when the customer context is set" do
      let(:options) { FriendlyShipping::Services::UpsJson::RatesOptions.new(shipper_number: "123456", customer_context: "H123454555") }

      it 'returns a hash with the required fields' do
        expect(subject[:RateRequest][:Request][:TransactionReference][:CustomerContext]).to eq("H123454555")
      end
    end

    context "when the pickup date is set" do
      let(:options) {
        FriendlyShipping::Services::UpsJson::RatesOptions.new(shipper_number: "123456", pickup_date: Time.parse("20240401 11:22:33"))
      }

      it 'returns a hash with the required fields' do
        expect(subject[:RateRequest][:Shipment][:DeliveryTimeInformation]).to eq({
                                                                                   PackageBillType: "03",
                                                                                   Pickup: {
                                                                                     Date: "20240401",
                                                                                     Time: "112233"
                                                                                   }
                                                                                 })
      end
    end

    context "when the shipping method is set" do
      let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: '03') }
      let(:options) {
        FriendlyShipping::Services::UpsJson::RatesOptions.new(shipper_number: "123456", shipping_method: shipping_method)
      }

      it 'returns a hash with the required fields' do
        expect(subject[:RateRequest][:Shipment][:Service][:Code]).to eq("03")
      end
    end

    context "when the shipment service options are set" do
      let(:options) {
        FriendlyShipping::Services::UpsJson::RatesOptions.new(shipper_number: "123456",
                                                              carbon_neutral: true,
                                                              saturday_delivery: true,
                                                              saturday_pickup: false)
      }

      it 'returns a hash with the required fields' do
        expect(subject[:RateRequest][:Shipment][:ShipmentServiceOptions]).to eq({ UPScarbonneutralIndicator: true, SaturdayDelivery: true, SaturdayPickup: false })
      end
    end

    context "when the negotiated rates option is set" do
      let(:options) {
        FriendlyShipping::Services::UpsJson::RatesOptions.new(negotiated_rates: true, shipper_number: "123456")
      }

      it 'returns a hash with the required fields' do
        expect(subject[:RateRequest][:Shipment][:NegotiatedRatesIndicator]).to be true
      end
    end
  end

  context "packages" do
    context "when rates are being requested" do
      it 'returns a package hash with the correct top level key name' do
        expect(subject[:RateRequest][:Shipment][:Package].first[:PackagingType][:Code]).to eq("02")
      end
    end

    context 'if the package has dimensions' do
      let(:dimensions) do
        [
          Measured::Length.new(30, :centimeters),
          Measured::Length.new(20, :centimeters),
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
        FactoryBot.build(:physical_shipment,
                         origin: origin,
                         destination: destination,
                         service_code: nil,
                         packages: [package, package])
      end

      it 'adds dimensions to the package' do
        dimensions = subject[:RateRequest][:Shipment][:Package].first[:Dimensions]
        expect(dimensions[:UnitOfMeasurement][:Code]).to eq('IN')
        expect(dimensions[:Length]).to eq('11.81')
        expect(dimensions[:Width]).to eq('7.87')
        expect(dimensions[:Height]).to eq('3.94')
      end

      context 'if a dimension is zero' do
        let(:dimensions) { [0, 1, 0].map { |n| Measured::Length(n, :cm) } }

        it 'does not add dimensions' do
          expect(subject[:RateRequest][:Shipment][:Package].first.key?(:Dimensions)).to be false
        end
      end

      context 'if generator is told to not transmit dimensions' do
        let(:package_options) do
          FriendlyShipping::Services::UpsJson::RatesPackageOptions.new(package_id: package.id, transmit_dimensions: false)
        end
        let(:options) do
          FriendlyShipping::Services::UpsJson::RatesOptions.new(shipper_number: '123454', package_options: [package_options])
        end

        subject(:call) { described_class.call(shipment: shipment, options: options) }

        it 'does not add dimensions' do
          expect(subject[:RateRequest][:Shipment][:Package].first.key?(:Dimensions)).to be false
        end
      end
    end
  end
end
