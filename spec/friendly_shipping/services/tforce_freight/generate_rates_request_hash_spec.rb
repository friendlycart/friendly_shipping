# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/tforce_freight/generate_rates_request_hash'
require 'friendly_shipping/services/tforce_freight/rates_options'

RSpec.describe FriendlyShipping::Services::TForceFreight::GenerateRatesRequestHash do
  describe ".call" do
    subject(:call) { described_class.call(shipment: shipment, options: options) }

    let(:shipment) { Physical::Shipment.new(packages: packages, origin: origin, destination: destination) }

    let(:origin) do
      Physical::Location.new(
        city: "Richmond",
        zip: "23224",
        region: "VA",
        country: "US"
      )
    end

    let(:destination) do
      Physical::Location.new(
        city: "Allanton",
        zip: "63025",
        region: "MO",
        country: "US"
      )
    end

    let(:packages) { [package_one] }

    let(:package_one) do
      Physical::Package.new(
        id: "my_package_1",
        items: [item_one]
      )
    end

    let(:item_one) do
      Physical::Item.new(
        id: "item_one",
        weight: Measured::Weight(500, :lbs),
        description: "Can of Socks"
      )
    end

    let(:options) do
      FriendlyShipping::Services::TForceFreight::RatesOptions.new(
        pickup_date: Date.parse("2023-05-18"),
        billing_address: billing_location,
        shipping_method: FriendlyShipping::ShippingMethod.new(service_code: "308"),
        billing: :prepaid,
        type: :l,
        density_eligible: true,
        accessorial_rate: true,
        time_in_transit: false,
        quote_number: true,
        pickup_options: %w[INPU LIFO],
        delivery_options: %w[INDE LIFD],
        customer_context: customer_context
      )
    end

    let(:customer_context) { "order-12345" }

    let(:billing_location) do
      Physical::Location.new(
        city: "Ducktown",
        zip: "54321",
        region: "NC",
        country: "US"
      )
    end

    let(:package_options) do
      [
        FriendlyShipping::Services::TForceFreight::RatesPackageOptions.new(
          package_id: package_one.id,
          item_options: item_one_options
        )
      ]
    end

    let(:item_one_options) do
      [
        FriendlyShipping::Services::TForceFreight::RatesItemOptions.new(
          item_id: "item_one",
          packaging: commodity_packaging,
          freight_class: "92.5",
          nmfc_primary_code: "16030",
          nmfc_sub_code: "01"
        )
      ]
    end

    let(:commodity_packaging) { :pallet }

    describe "keys" do
      subject(:keys) { call.keys }

      it do
        is_expected.to eq(
          %i[
            requestOptions
            shipFrom
            shipTo
            payment
            serviceOptions
            commodities
          ]
        )
      end
    end

    describe "requestOptions" do
      subject(:request_options) { call[:requestOptions] }

      it do
        is_expected.to eq(
          serviceCode: "308",
          pickupDate: "2023-05-18",
          type: "L",
          densityEligible: true,
          gfpOptions: {
            accessorialRate: true,
          },
          timeInTransit: false,
          quoteNumber: true,
          customerContext: "order-12345"
        )
      end

      context "when values are missing" do
        let(:options) do
          FriendlyShipping::Services::TForceFreight::RatesOptions.new(
            pickup_date: Date.parse("2024-01-05"),
            billing_address: billing_location,
            shipping_method: FriendlyShipping::ShippingMethod.new(service_code: "308")
          )
        end

        it do
          is_expected.to eq(
            {
              serviceCode: "308",
              pickupDate: "2024-01-05",
              type: "L",
              densityEligible: false,
              gfpOptions: {
                accessorialRate: false
              },
              timeInTransit: true,
              quoteNumber: false
            }
          )
        end
      end
    end

    describe "shipFrom" do
      subject(:ship_from) { call[:shipFrom] }

      it do
        is_expected.to eq(
          address: {
            city: "Richmond",
            country: "US",
            postalCode: "23224",
            stateProvinceCode: "VA"
          }
        )
      end
    end

    describe "shipTo" do
      subject(:ship_to) { call[:shipTo] }

      it do
        is_expected.to eq(
          address: {
            city: "Allanton",
            country: "US",
            postalCode: "63025",
            stateProvinceCode: "MO"
          }
        )
      end
    end

    describe "payment" do
      subject(:payment) { call[:payment] }

      it do
        is_expected.to eq(
          billingCode: "10",
          payer: {
            address: {
              city: "Ducktown",
              stateProvinceCode: "NC",
              postalCode: "54321",
              country: "US"
            }
          }
        )
      end
    end

    describe "serviceOptions" do
      subject(:service_options) { call[:serviceOptions] }

      it do
        is_expected.to eq(
          pickup: %w[INPU LIFO],
          delivery: %w[INDE LIFD]
        )
      end
    end

    describe "commodities" do
      subject(:commodity) { call[:commodities] }

      before do
        expect(FriendlyShipping::Services::TForceFreight::GenerateCommodityInformation).
          to receive(:call).with(shipment: shipment, options: options).and_return("results").once
      end

      it { is_expected.to eq("results") }
    end
  end
end
