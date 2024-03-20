# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngineLTL::SerializeQuoteRequest do
  subject { described_class.call(shipment: shipment, options: options) }

  let(:shipment) do
    FactoryBot.build(
      :physical_shipment,
      origin: origin,
      destination: destination,
      structures: [pallet_1, pallet_2],
      packages: nil
    )
  end

  let(:options) do
    FriendlyShipping::Services::ShipEngineLTL::QuoteOptions.new(
      service_code: "stnd",
      pickup_date: Time.parse("2023-07-19 10:30:00 UTC"),
      accessorial_service_codes: %w[LFTP IPU],
      structure_options: [
        FriendlyShipping::Services::ShipEngineLTL::StructureOptions.new(
          structure_id: "pallet 1",
          package_options: [
            FriendlyShipping::Services::ShipEngineLTL::PackageOptions.new(
              package_id: "package 1",
              packaging_code: "box",
              freight_class: "92.5",
              nmfc_code: "16030 sub 1"
            )
          ]
        ),
        FriendlyShipping::Services::ShipEngineLTL::StructureOptions.new(
          structure_id: "pallet 2",
          package_options: [
            FriendlyShipping::Services::ShipEngineLTL::PackageOptions.new(
              package_id: "package 2",
              packaging_code: "box",
              freight_class: "92.5",
              nmfc_code: "16030 sub 1"
            )
          ]
        )
      ],
      packages_serializer_class: nil
    )
  end

  let(:pallet_1) do
    FactoryBot.build(
      :physical_structure,
      id: "pallet 1",
      packages: [package_1]
    )
  end

  let(:pallet_2) do
    FactoryBot.build(
      :physical_structure,
      id: "pallet 2",
      packages: [package_2]
    )
  end

  let(:package_1) do
    FactoryBot.build(
      :physical_package,
      id: "package 1",
      description: "Tumblers",
      items: [
        Physical::Item.new(
          weight: Measured::Weight(10.53, :lb)
        )
      ],
      container: Physical::Box.new(
        dimensions: [
          Measured::Length(7.874, :in),
          Measured::Length(5.906, :in),
          Measured::Length(11.811, :in)
        ]
      )
    )
  end

  let(:package_2) do
    FactoryBot.build(
      :physical_package,
      id: "package 2",
      description: "Wicks",
      items: [
        Physical::Item.new(
          weight: Measured::Weight(1.06, :lb)
        )
      ],
      container: Physical::Box.new(
        dimensions: [
          Measured::Length(4.341, :in),
          Measured::Length(2.354, :in),
          Measured::Length(1.902, :in)
        ]
      )
    )
  end

  let(:origin) do
    FactoryBot.build(
      :physical_location,
      name: "John Smith",
      company_name: "ACME Inc",
      address1: "123 Maple St",
      city: "New York",
      region: "NY",
      zip: "10001",
      phone: "123-123-1234",
      email: "john@smith.com",
      properties: { account_number: "abc123" }
    )
  end

  let(:destination) do
    FactoryBot.build(
      :physical_location,
      name: "Jane Doe",
      company_name: "Widgets LLC",
      address1: "456 Oak St",
      city: "Boulder",
      region: "CO",
      zip: "80301",
      phone: "555-678-1234",
      email: "jane@doe.com",
      properties: { account_number: "def456" }
    )
  end

  it do
    is_expected.to eq(
      {
        shipment: {
          service_code: "stnd",
          ship_from: {
            account: "abc123",
            address: {
              company_name: "ACME Inc",
              address_line1: "123 Maple St",
              city_locality: "New York",
              state_province: "NY",
              postal_code: "10001",
              country_code: "US"
            },
            contact: {
              name: "John Smith",
              phone_number: "123-123-1234",
              email: "john@smith.com"
            }
          },
          ship_to: {
            account: "def456",
            address: {
              company_name: "Widgets LLC",
              address_line1: "456 Oak St",
              city_locality: "Boulder",
              state_province: "CO",
              postal_code: "80301",
              country_code: "US"
            },
            contact: {
              name: "Jane Doe",
              phone_number: "555-678-1234",
              email: "jane@doe.com"
            }
          },
          bill_to: {
            account: "abc123",
            address: {
              company_name: "ACME Inc",
              address_line1: "123 Maple St",
              city_locality: "New York",
              state_province: "NY",
              postal_code: "10001",
              country_code: "US"
            },
            contact: {
              name: "John Smith",
              phone_number: "123-123-1234",
              email: "john@smith.com"
            },
            payment_terms: "prepaid",
            type: "shipper"
          },
          options: [
            { code: "LFTP" },
            { code: "IPU" }
          ],
          packages: [
            {
              code: "box",
              description: "Tumblers",
              freight_class: "92.5",
              nmfc_code: "16030 sub 1",
              weight: {
                unit: "pounds",
                value: 11
              },
              dimensions: {
                length: 8,
                width: 6,
                height: 12,
                unit: "inches"
              },
              quantity: 1,
              stackable: true,
              hazardous_materials: false
            },
            {
              code: "box",
              description: "Wicks",
              freight_class: "92.5",
              nmfc_code: "16030 sub 1",
              weight: {
                unit: "pounds",
                value: 2
              },
              dimensions: {
                length: 5,
                width: 3,
                height: 2,
                unit: "inches"
              },
              quantity: 1,
              stackable: true,
              hazardous_materials: false
            }
          ],
          pickup_date: "2023-07-19",
          requested_by: {
            company_name: "ACME Inc",
            contact: {
              email: "john@smith.com",
              name: "John Smith",
              phone_number: "123-123-1234"
            }
          },
        },
        shipment_measurements: {
          total_linear_length: {
            unit: "inches",
            value: 63
          },
          total_width: {
            unit: "inches",
            value: 48
          },
          total_height: {
            unit: "inches",
            value: 65
          },
          total_weight: {
            unit: "pounds",
            value: 109
          }
        }
      }
    )
  end

  describe "deprecated packages behavior" do
    # TODO: Remove when packages_serializer_class is removed

    let(:shipment) do
      FactoryBot.build(
        :physical_shipment,
        origin: origin,
        destination: destination,
        packages: [package_1, package_2]
      )
    end

    let(:options) do
      FriendlyShipping::Services::ShipEngineLTL::QuoteOptions.new(
        service_code: "stnd",
        pickup_date: Time.parse("2023-07-19 10:30:00 UTC"),
        accessorial_service_codes: %w[LFTP IPU],
        package_options: [
          FriendlyShipping::Services::ShipEngineLTL::PackageOptions.new(
            package_id: "package 1",
            item_options: [
              FriendlyShipping::Services::ShipEngineLTL::ItemOptions.new(
                item_id: "item 1",
                packaging_code: "box",
                freight_class: "92.5",
                nmfc_code: "16030 sub 1"
              )
            ]
          ),
          FriendlyShipping::Services::ShipEngineLTL::PackageOptions.new(
            package_id: "package 2",
            item_options: [
              FriendlyShipping::Services::ShipEngineLTL::ItemOptions.new(
                item_id: "item 2",
                packaging_code: "box",
                freight_class: "92.5",
                nmfc_code: "16030 sub 1"
              )
            ]
          )
        ]
      )
    end

    let(:package_1) do
      FactoryBot.build(
        :physical_package,
        id: "package 1",
        items: [item_1],
        container: container
      )
    end

    let(:package_2) do
      FactoryBot.build(
        :physical_package,
        id: "package 2",
        items: [item_2],
        container: container
      )
    end

    let(:container) do
      FactoryBot.build(:physical_pallet)
    end

    let(:item_1) do
      FactoryBot.build(
        :physical_item,
        id: "item 1",
        description: "Tumblers",
        weight: Measured::Weight(10.53, :lb),
        dimensions: [
          Measured::Length(7.874, :in),
          Measured::Length(5.906, :in),
          Measured::Length(11.811, :in)
        ]
      )
    end

    let(:item_2) do
      FactoryBot.build(
        :physical_item,
        id: "item 2",
        description: "Wicks",
        weight: Measured::Weight(1.06, :lb),
        dimensions: [
          Measured::Length(4.341, :in),
          Measured::Length(2.354, :in),
          Measured::Length(1.902, :in)
        ]
      )
    end

    let(:origin) do
      FactoryBot.build(
        :physical_location,
        name: "John Smith",
        company_name: "ACME Inc",
        address1: "123 Maple St",
        city: "New York",
        region: "NY",
        zip: "10001",
        phone: "123-123-1234",
        email: "john@smith.com",
        properties: { account_number: "abc123" }
      )
    end

    let(:destination) do
      FactoryBot.build(
        :physical_location,
        name: "Jane Doe",
        company_name: "Widgets LLC",
        address1: "456 Oak St",
        city: "Boulder",
        region: "CO",
        zip: "80301",
        phone: "555-678-1234",
        email: "jane@doe.com",
        properties: { account_number: "def456" }
      )
    end

    it do
      is_expected.to eq(
        {
          shipment: {
            service_code: "stnd",
            ship_from: {
              account: "abc123",
              address: {
                company_name: "ACME Inc",
                address_line1: "123 Maple St",
                city_locality: "New York",
                state_province: "NY",
                postal_code: "10001",
                country_code: "US"
              },
              contact: {
                name: "John Smith",
                phone_number: "123-123-1234",
                email: "john@smith.com"
              }
            },
            ship_to: {
              account: "def456",
              address: {
                company_name: "Widgets LLC",
                address_line1: "456 Oak St",
                city_locality: "Boulder",
                state_province: "CO",
                postal_code: "80301",
                country_code: "US"
              },
              contact: {
                name: "Jane Doe",
                phone_number: "555-678-1234",
                email: "jane@doe.com"
              }
            },
            bill_to: {
              account: "abc123",
              address: {
                company_name: "ACME Inc",
                address_line1: "123 Maple St",
                city_locality: "New York",
                state_province: "NY",
                postal_code: "10001",
                country_code: "US"
              },
              contact: {
                name: "John Smith",
                phone_number: "123-123-1234",
                email: "john@smith.com"
              },
              payment_terms: "prepaid",
              type: "shipper"
            },
            options: [
              { code: "LFTP" },
              { code: "IPU" }
            ],
            packages: [
              {
                code: "box",
                description: "Tumblers",
                freight_class: "92.5",
                nmfc_code: "16030 sub 1",
                weight: {
                  unit: "pounds",
                  value: 11
                },
                dimensions: {
                  length: 8,
                  width: 6,
                  height: 12,
                  unit: "inches"
                },
                quantity: 1,
                stackable: true,
                hazardous_materials: false
              },
              {
                code: "box",
                description: "Wicks",
                freight_class: "92.5",
                nmfc_code: "16030 sub 1",
                weight: {
                  unit: "pounds",
                  value: 2
                },
                dimensions: {
                  length: 5,
                  width: 3,
                  height: 2,
                  unit: "inches"
                },
                quantity: 1,
                stackable: true,
                hazardous_materials: false
              }
            ],
            pickup_date: "2023-07-19",
            requested_by: {
              company_name: "ACME Inc",
              contact: {
                email: "john@smith.com",
                name: "John Smith",
                phone_number: "123-123-1234"
              }
            },
          },
          shipment_measurements: {
            total_linear_length: {
              unit: "inches",
              value: 63
            },
            total_width: {
              unit: "inches",
              value: 48
            },
            total_height: {
              unit: "inches",
              value: 65
            },
            total_weight: {
              unit: "pounds",
              value: 179
            }
          }
        }
      )
    end
  end
end
