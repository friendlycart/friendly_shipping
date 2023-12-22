# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/tforce_freight'

RSpec.describe FriendlyShipping::Services::TForceFreight do
  let(:service) { described_class.new(access_token: "secret-token") }

  describe "carriers" do
    subject { service.carriers.value! }

    it "has only one carrier with four shipping methods" do
      expect(subject.length).to eq(1)
      expect(subject.first.shipping_methods.map(&:service_code)).to contain_exactly(
        "308", "309", "334", "349"
      )
      expect(subject.first.shipping_methods.map(&:name)).to contain_exactly(
        "TForce Freight LTL",
        "TForce Freight LTL - Guaranteed",
        "TForce Freight LTL - Guaranteed A.M.",
        "TForce Standard LTL",
      )
    end
  end

  describe "#rates" do
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
        city: "Eureka",
        zip: "63025",
        region: "MO",
        country: "US"
      )
    end

    let(:packages) { [package_one, package_two] }

    let(:package_one) do
      Physical::Package.new(
        id: "my_package_1",
        items: [item_one]
      )
    end

    let(:package_two) do
      Physical::Package.new(
        id: "my_package_2",
        items: [item_two]
      )
    end

    let(:item_one) do
      Physical::Item.new(
        id: "item_one",
        weight: Measured::Weight(500, :lbs)
      )
    end

    let(:item_two) do
      Physical::Item.new(
        id: "item_two",
        weight: Measured::Weight(500, :lbs)
      )
    end

    let(:options) do
      FriendlyShipping::Services::TForceFreight::RatesOptions.new(
        pickup_date: Date.today,
        shipping_method: FriendlyShipping::ShippingMethod.new(service_code: "308"),
        billing_address: billing_location,
        customer_context: customer_context,
        package_options: package_options
      )
    end

    let(:customer_context) { "order-12345" }

    let(:billing_location) do
      Physical::Location.new(
        city: "Durham",
        zip: "27703",
        region: "NC",
        country: "US"
      )
    end

    let(:package_options) do
      [
        FriendlyShipping::Services::TForceFreight::RatesPackageOptions.new(
          package_id: package_one.id,
          item_options: item_one_options
        ),
        FriendlyShipping::Services::TForceFreight::RatesPackageOptions.new(
          package_id: package_two.id,
          item_options: item_two_options
        )
      ]
    end

    let(:item_one_options) do
      [
        FriendlyShipping::Services::TForceFreight::RatesItemOptions.new(
          item_id: "item_one",
          packaging: :carton,
          freight_class: "92.5",
          nmfc_primary_code: "16030",
          nmfc_sub_code: "1"
        )
      ]
    end

    let(:item_two_options) do
      [
        FriendlyShipping::Services::TForceFreight::RatesItemOptions.new(
          item_id: "item_two",
          packaging: :pallet,
          freight_class: "92.5",
          nmfc_primary_code: "16030",
          nmfc_sub_code: "1"
        )
      ]
    end

    subject { service.rates(shipment, options: options) }

    context "with a valid request", vcr: { cassette_name: "tforce_freight/rates/success", match_requests_on: [:method, :uri, :content_type] } do
      it { is_expected.to be_success }

      it "has all the right data" do
        rates = subject.value!.data
        expect(rates.length).to eq(3)
        rate = rates.first
        expect(rate).to be_a(FriendlyShipping::Rate)
        expect(rate.total_amount).to eq(Money.new(157_356, "USD"))
        expect(rate.shipping_method.name).to eq("TForce Freight LTL")
        expect(rate.data[:days_in_transit]).to eq(3)
      end
    end

    context "with a missing destination postal code", vcr: { cassette_name: "tforce_freight/rates/failure", match_requests_on: [:method, :uri, :content_type] } do
      let(:destination) do
        Physical::Location.new(
          company_name: "Consignee Test 1",
          city: "Allanton",
          region: "MO",
          country: "US"
        )
      end

      it { is_expected.to be_failure }

      it "has the correct error message" do
        expect(subject.failure.to_s).to include("Invalid type. Expected String but got Null.")
      end
    end
  end
end