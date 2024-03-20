# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngineLTL::SerializeStructures do
  subject { described_class.call(structures: structures, options: options) }

  let(:structures) { [structure_1, structure_2] }

  let(:options) do
    FriendlyShipping::Services::ShipEngineLTL::QuoteOptions.new(
      service_code: "stnd",
      pickup_date: Time.parse("2023-07-19 10:30:00 UTC"),
      accessorial_service_codes: %w[LFTP IPU],
      structure_options: [
        FriendlyShipping::Services::ShipEngineLTL::StructureOptions.new(
          structure_id: "structure 1",
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
          structure_id: "structure 2",
          package_options: [
            FriendlyShipping::Services::ShipEngineLTL::PackageOptions.new(
              package_id: "package 2",
              packaging_code: "box",
              freight_class: "92.5",
              nmfc_code: "16030 sub 1"
            )
          ]
        )
      ]
    )
  end

  let(:structure_1) do
    FactoryBot.build(
      :physical_structure,
      id: "structure 1",
      packages: [package_1]
    )
  end

  let(:structure_2) do
    FactoryBot.build(
      :physical_structure,
      id: "structure 2",
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

  it do
    is_expected.to eq(
      [
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
      ]
    )
  end
end
