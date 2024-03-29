# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::SerializeRatesRequest do
  subject { described_class.call(shipment: shipment, options: options) }

  let(:container) { FactoryBot.build(:physical_box, weight: Measured::Weight(0, :g)) }
  let(:item) { FactoryBot.build(:physical_item, description: "Wicks", sku: "20010", weight: Measured::Weight(1, :ounce), cost: Money.new(2500, "USD")) }
  let(:package) { FactoryBot.build(:physical_package, items: [item], void_fill_density: Measured::Density(0, :g_ml), container: container) }
  let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package]) }
  let(:carrier) { FriendlyShipping::Carrier.new(id: "se-123456") }
  let(:ship_date) { Time.parse("2023-08-01") }

  let(:options) do
    FriendlyShipping::Services::ShipEngine::RatesOptions.new(
      carriers: [carrier],
      service_code: "usps_priority_mail",
      ship_date: ship_date,
      comparison_rate_type: "retail",
      package_options: [
        FriendlyShipping::Services::ShipEngine::RatesPackageOptions.new(
          package_id: "package 1",
          item_options: [
            FriendlyShipping::Services::ShipEngine::RatesItemOptions.new(
              item_id: "item 1",
              commodity_code: "6116.10.0000",
              country_of_origin: "US"
            )
          ]
        )
      ]
    )
  end

  it do
    is_expected.to match(
      hash_including(
        shipment: {
          carrier_ids: ["se-123456"],
          service_code: "usps_priority_mail",
          ship_date: "2023-08-01",
          ship_to: {
            name: shipment.destination.name,
            phone: shipment.destination.phone,
            company_name: shipment.destination.company_name,
            address_line1: shipment.destination.address1,
            address_line2: shipment.destination.address2,
            city_locality: shipment.destination.city,
            state_province: shipment.destination.region.code,
            postal_code: shipment.destination.zip,
            country_code: shipment.destination.country.code,
            address_residential_indicator: "unknown"
          },
          ship_from: {
            name: shipment.origin.name,
            phone: shipment.origin.phone,
            company_name: shipment.origin.company_name,
            address_line1: shipment.origin.address1,
            address_line2: shipment.origin.address2,
            city_locality: shipment.origin.city,
            state_province: shipment.origin.region.code,
            postal_code: shipment.origin.zip,
            country_code: shipment.origin.country.code,
            address_residential_indicator: "unknown"
          },
          items: [{
            name: "Wicks",
            sku: "20010",
            quantity: 1
          }],
          packages: [{
            weight: {
              value: 0.06,
              unit: "pound"
            },
            dimensions: {
              height: 11.81,
              length: 7.87,
              width: 5.91,
              unit: "inch"
            },
            products: [{
              description: "Wicks",
              sku: "20010",
              quantity: 1,
              country_of_origin: nil,
              harmonized_tariff_code: nil,
              value: {
                amount: 25,
                currency: "USD"
              }
            }]
          }],
          comparison_rate_type: "retail",
          confirmation: "none",
          address_residential_indicator: "unknown"
        },
        rate_options: {
          carrier_ids: ["se-123456"],
          service_codes: ["usps_priority_mail"]
        }
      )
    )
  end

  context "with missing values" do
    let(:shipment) { FactoryBot.build(:physical_shipment, packages: []) }
    let(:options) do
      FriendlyShipping::Services::ShipEngine::RatesOptions.new(
        carriers: [carrier],
        service_code: "usps_priority_mail"
      )
    end

    it do
      is_expected.to match(
        shipment: hash_including(
          address_residential_indicator: "unknown",
          carrier_ids: ["se-123456"],
          confirmation: "none",
          service_code: "usps_priority_mail",
          ship_date: Time.now.strftime("%Y-%m-%d")
        ),
        rate_options: {
          carrier_ids: ["se-123456"],
          service_codes: ["usps_priority_mail"]
        }
      )
    end
  end
end
