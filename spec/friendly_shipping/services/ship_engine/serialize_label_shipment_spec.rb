require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::SerializeLabelShipment do
  let(:container) { FactoryBot.build(:physical_box, weight: Measured::Weight(0, :g)) }
  let(:item) { FactoryBot.build(:physical_item, weight: Measured::Weight(1, :ounce)) }
  let(:package) { FactoryBot.build(:physical_package, items: [item], void_fill_density: Measured::Weight(0, :g), container: container) }
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
          packages: array_including(
            hash_including(
              weight: hash_including(
                value: 1.0,
                unit: "ounce"
              ),
              dimensions: hash_including(
                unit: "inch",
                length: 15.75,
                width: 19.69,
                height: 23.62,
              )
            )
          )
        )
      )
    )
  end

  context 'if the container is a special USPS thing' do
    let(:container) { FactoryBot.build(:physical_box, weight: Measured::Weight(0, :g), properties: { usps_package_code: "large_flat_rate_box" }) }

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

  context 'if passing a reference number' do
    let(:container) do
      FactoryBot.build(
        :physical_box,
        weight: Measured::Weight(0, :g),
        properties: {
          usps_label_messages: {
            reference1: "There's such a chill"
          }
        }
      )
    end

    it 'includes that reference number' do
      is_expected.to match(
        hash_including(
          shipment: hash_including(
            packages: array_including(
              hash_including(label_messages: { reference1: "There's such a chill" })
            )
          )
        )
      )
    end
  end

  context 'if passing two reference numbers' do
    let(:container) do
      FactoryBot.build(
        :physical_box,
        weight: Measured::Weight(0, :g),
        properties: {
          usps_label_messages: {
            reference1: "There's such a chill",
            reference2: "Wake from your sleep"
          }
        }
      )
    end

    it 'includes that reference number' do
      is_expected.to match(
        hash_including(
          shipment: hash_including(
            packages: array_including(
              hash_including(
                label_messages: {
                  reference1: "There's such a chill",
                  reference2: "Wake from your sleep"
                }
              )
            )
          )
        )
      )
    end
  end

  context 'if passing a carrier id' do
    let(:shipment_options) { {carrier_id: 'se-12345'} }

    it 'includes the carrier ID' do
      is_expected.to match(
        hash_including(
          shipment: hash_including(carrier_id: 'se-12345')
        )
      )
    end
  end
  
  context 'if weight is between 15.9 and 16 oz' do
    let(:item) { FactoryBot.build(:physical_item, weight: Measured::Weight(15.95, :ounce)) }
    
    # Max weight for USPS First Class is 15.9 oz, not 16 oz
    it 'returns weight as 15.9 oz' do
      is_expected.to match(
        hash_including(
          shipment: hash_including(
            packages: array_including(
              hash_including(
                weight: hash_including(
                  value: 15.9,
                  unit: "ounce"
                )
              )
            )
          )
        )
      )
    end
  end
end
