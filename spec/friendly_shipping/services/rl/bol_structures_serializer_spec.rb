# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::BOLStructuresSerializer do
  subject do
    described_class.call(
      structures: [pallet_1, pallet_2],
      options: options
    )
  end

  let(:pickup_time_window) do
    Time.parse("2023-08-01 09:00:00 UTC")..Time.parse("2023-08-01 17:00:00 UTC")
  end

  let(:options) do
    FriendlyShipping::Services::RL::BOLOptions.new(
      pickup_time_window: pickup_time_window,
      structure_options: [
        FriendlyShipping::Services::RL::StructureOptions.new(
          structure_id: "pallet 1",
          package_options: [
            FriendlyShipping::Services::RL::PackageOptions.new(
              package_id: "package 1",
              nmfc_primary_code: "87700",
              nmfc_sub_code: "07",
              freight_class: "92.5"
            )
          ]
        ),
        FriendlyShipping::Services::RL::StructureOptions.new(
          structure_id: "pallet 2",
          package_options: [
            FriendlyShipping::Services::RL::PackageOptions.new(
              package_id: "package 2",
              nmfc_primary_code: "87700",
              nmfc_sub_code: "07",
              freight_class: "92.5"
            )
          ]
        )
      ]
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
      dimensions: [
        Measured::Length(7.874, :in),
        Measured::Length(5.906, :in),
        Measured::Length(11.811, :in)
      ],
      items: [
        Physical::Item.new(
          weight: Measured::Weight(10.53, :lb)
        )
      ]
    )
  end

  let(:package_2) do
    FactoryBot.build(
      :physical_package,
      id: "package 2",
      description: "Wicks",
      dimensions: [
        Measured::Length(4.341, :in),
        Measured::Length(2.354, :in),
        Measured::Length(1.902, :in)
      ],
      items: [
        Physical::Item.new(
          weight: Measured::Weight(1.06, :lb)
        )
      ]
    )
  end

  it do
    is_expected.to eq(
      [
        {
          IsHazmat: false,
          PackageType: "BOX",
          Pieces: 1,
          NMFCItemNumber: "87700",
          NMFCSubNumber: "07",
          Class: "92.5",
          Weight: 11,
          Description: "Tumblers"
        }, {
          IsHazmat: false,
          PackageType: "BOX",
          Pieces: 1,
          NMFCItemNumber: "87700",
          NMFCSubNumber: "07",
          Class: "92.5",
          Weight: 2,
          Description: "Wicks"
        }
      ]
    )
  end
end
