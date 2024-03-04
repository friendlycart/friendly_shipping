# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::SerializeRateEstimateRequest do
  subject { described_class.call(shipment: shipment, options: options) }

  let(:container) { FactoryBot.build(:physical_box, weight: Measured::Weight(0, :g)) }
  let(:item) { FactoryBot.build(:physical_item, weight: Measured::Weight(1, :ounce)) }
  let(:package) { FactoryBot.build(:physical_package, items: [item], void_fill_density: Measured::Density(0, :g_ml), container: container) }
  let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package]) }
  let(:carrier) { FriendlyShipping::Carrier.new(id: "se-123456") }
  let(:options) { FriendlyShipping::Services::ShipEngine::RateEstimatesOptions.new(carriers: [carrier], ship_date: ship_date) }
  let(:ship_date) { Time.parse("2023-08-01") }

  it do
    is_expected.to match(
      hash_including(
        carrier_ids: ["se-123456"],
        from_country_code: "US",
        from_postal_code: shipment.origin.zip,
        to_country_code: "US",
        to_postal_code: shipment.destination.zip,
        to_city_locality: "Herndon",
        to_state_province: "VA",
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
        confirmation: "none",
        address_residential_indicator: "unknown",
        ship_date: "2023-08-01"
      )
    )
  end
end
