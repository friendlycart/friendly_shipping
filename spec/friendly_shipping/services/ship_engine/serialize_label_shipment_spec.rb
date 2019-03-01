require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::SerializeLabelShipment do
  let(:container) { FactoryBot.build(:physical_box, weight: 0) }
  let(:item) { FactoryBot.build(:physical_item, weight: 1, weight_unit: :ounce) }
  let(:package) { FactoryBot.build(:physical_package, items: [item], void_fill_density: 0, container: container) }
  let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package], options: shipment_options) }
  let(:shipment_options) { {label_format: 'zpl'} }
  subject { described_class.new(shipment: shipment).call }

  it do
    is_expected.to match(
      hash_including(
        label_format: "zpl",
        label_download_type: "url",
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
              package_code: "package",
              weight: {
                value: 1.0,
                unit: "ounce"
              },
              dimensions: {
                unit: "inch",
                width: 15.75,
                height: 19.69,
                length: 23.62
              }
            }
          ]
        )
      )
    )
  end

  context 'if the container is a special USPS thing' do
    let(:container) { FactoryBot.build(:physical_box, weight: 0, properties: { usps_package_code: "large_flat_rate_box" }) }

    it 'does not include the dimensions array' do
      is_expected.to match(
        hash_including(
          shipment: hash_including(
            packages: array_including(
              hash_not_including(:dimensions)
            )
          )
        )
      )
    end
  end

  context 'if requesting inline labels' do
    let(:shipment_options) { {label_download_type: 'inline'} }

     it 'includes the label download type' do
      is_expected.to match(
        hash_including(
          label_download_type: 'inline'
        )
      )
    end
  end
end
