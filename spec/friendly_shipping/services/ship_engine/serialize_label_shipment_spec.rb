# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::SerializeLabelShipment do
  let(:container) { FactoryBot.build(:physical_box, weight: Measured::Weight(0, :g)) }
  let(:item) { FactoryBot.build(:physical_item, weight: Measured::Weight(1, :ounce)) }
  let(:package) { FactoryBot.build(:physical_package, items: [item], void_fill_density: Measured::Density(0, :g_ml), container: container) }
  let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package]) }
  let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: 'usps_priority_mail') }
  let(:package_options) { Set.new }
  let(:options) do
    FriendlyShipping::Services::ShipEngine::LabelOptions.new(
      shipping_method: shipping_method,
      label_format: :zpl,
      package_options: package_options
    )
  end

  subject { described_class.call(shipment: shipment, options: options, test: true) }

  it do
    is_expected.to match(
      hash_including(
        test_label: true,
        label_format: :zpl,
        label_download_type: :url,
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
                length: 7.87,
                width: 5.91,
                height: 11.81,
              )
            )
          )
        )
      )
    )
  end

  it 'does not include label_image_id by default' do
    is_expected.not_to match(hash_including(:label_image_id))
  end

  context 'if the container is a special USPS thing' do
    let(:package_options) do
      [
        FriendlyShipping::Services::ShipEngine::LabelPackageOptions.new(
          package_id: package.id,
          package_code: :large_flat_rate_box
        )
      ]
    end

    it 'still includes the dimensions array' do
      is_expected.to match(
        hash_including(
          shipment: hash_including(
            packages: array_including(
              hash_including(:dimensions)
            )
          )
        )
      )
    end
  end

  context 'if requesting inline labels' do
    let(:options) do
      FriendlyShipping::Services::ShipEngine::LabelOptions.new(
        shipping_method: shipping_method,
        label_download_type: :inline,
        package_options: package_options
      )
    end

    it 'includes the label download type' do
      is_expected.to match(
        hash_including(
          label_download_type: :inline
        )
      )
    end
  end

  context 'if passing a reference number' do
    let(:package_options) do
      [
        FriendlyShipping::Services::ShipEngine::LabelPackageOptions.new(
          package_id: package.id,
          messages: ["There's such a chill"]
        )
      ]
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
    let(:package_options) do
      [
        FriendlyShipping::Services::ShipEngine::LabelPackageOptions.new(
          package_id: package.id,
          messages: ["There's such a chill", "Wake from your sleep"]
        )
      ]
    end

    it 'includes those references' do
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
    let(:carrier) { FriendlyShipping::Carrier.new(id: 'se-12345') }
    let(:shipping_method) do
      FriendlyShipping::ShippingMethod.new(
        service_code: 'usps_priority_mail',
        carrier: carrier
      )
    end

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

  context 'if passing a label image id' do
    let(:options) do
      FriendlyShipping::Services::ShipEngine::LabelOptions.new(
        shipping_method: shipping_method,
        label_image_id: "img_DtBXupDBxREpHnwEXhTfgK",
        label_format: :zpl,
        package_options: package_options
      )
    end

    it do
      is_expected.to match(hash_including(label_image_id: "img_DtBXupDBxREpHnwEXhTfgK"))
    end
  end

  context "with international shipment" do
    let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package], origin: origin, destination: destination) }
    let(:item) { FactoryBot.build(:physical_item, sku: "20010", description: "Wicks", cost: Money.new(120, "CAD")) }

    let(:origin) { FactoryBot.build(:physical_location, region_code: "NC", country_code: "US") }
    let(:destination) { FactoryBot.build(:physical_location, region_code: "ON", country_code: "CA") }

    let(:package_options) do
      [
        FriendlyShipping::Services::ShipEngine::LabelPackageOptions.new(
          package_id: package.id,
          package_code: :large_flat_rate_box,
          item_options: item_options
        )
      ]
    end

    let(:item_options) do
      [
        FriendlyShipping::Services::ShipEngine::LabelItemOptions.new(
          item_id: item.id,
          commodity_code: "6116.10.0000",
          country_of_origin: "US"
        )
      ]
    end

    it do
      is_expected.to match(
        hash_including(
          shipment: hash_including(
            customs: {
              contents: "merchandise",
              non_delivery: "return_to_sender",
              customs_items: [{
                sku: "20010",
                description: "Wicks",
                quantity: 1,
                value: {
                  amount: 1.20,
                  currency: "CAD"
                },
                harmonized_tariff_code: "6116.10.0000",
                country_of_origin: "US"
              }]
            }
          )
        )
      )
    end
  end
end
