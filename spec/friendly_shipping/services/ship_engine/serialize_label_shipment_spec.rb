require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::SerializeLabelShipment do
  let(:container) { FactoryBot.build(:physical_box, weight: 0) }
  let(:item) { FactoryBot.build(:physical_item, weight: 1, weight_unit: :ounce) }
  let(:package) { FactoryBot.build(:physical_package, items: [item], void_fill_density: 0, container: container) }
  let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package], options: {label_format: 'zpl'}) }
  subject { described_class.new(shipment: shipment).call }

  it do
    is_expected.to match(
      hash_including(
        label_format: "zpl",
        shipment: hash_including(
          service_code: 'usps_priority_mail',
          ship_to: hash_including(
            name: "Jane Doe",
            phone: "555-555-0199",
            company_name: "Company",
            address_line1: "11 Lovely Street",
            address_line2: "South",
            city_locality: "Herndon",
            state_province: "IL",
            postal_code: shipment.destination.zip,
            country_code: "US",
            address_residential_indicator: "No"
          ),
          ship_from: hash_including(
            name: "Jane Doe",
            phone: "555-555-0199",
            company_name: "Company",
            address_line1: "11 Lovely Street",
            address_line2: "South",
            city_locality: "Herndon",
            state_province: "IL",
            postal_code: shipment.origin.zip,
            country_code: "US",
            address_residential_indicator: "No"
          ),
          packages:[
            {
              weight: {
                value: 1.0,
                unit: "ounce"
              }
            }
          ]
        )
      )
    )
  end
end
