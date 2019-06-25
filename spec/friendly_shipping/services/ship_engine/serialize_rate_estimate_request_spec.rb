require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::SerializeRateEstimateRequest do
  let(:container) { FactoryBot.build(:physical_box, weight: Measured::Weight(0, :g)) }
  let(:item) { FactoryBot.build(:physical_item, weight: Measured::Weight(1, :ounce)) }
  let(:package) { FactoryBot.build(:physical_package, items: [item], void_fill_density: Measured::Weight(0, :g), container: container) }
  let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package]) }
  let(:carrier) { FriendlyShipping::Carrier.new(id: 'se-123456') }
  subject { described_class.call(shipment: shipment, carriers: [carrier]) }

  it do
    is_expected.to match(hash_including(
      carrier_ids: ["se-123456"],
      from_country_code: "US",
      from_postal_code: shipment.origin.zip,
      to_country_code: "US",
      to_postal_code: shipment.destination.zip,
      to_city_locality: "Herndon",
      to_state_province: "IL",
      weight: {value: 0.0625, unit: "pound"},
      confirmation: "none",
      address_residential_indicator: "no"
    ))
  end
end
