# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::BOLHandlingUnitsSerializer do
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
          handling_unit: :pallet,
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
          handling_unit: :skid,
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
      container: FactoryBot.build(
        :physical_pallet,
        dimensions: [
          Measured::Length(48, :in),
          Measured::Length(40, :in),
          Measured::Length(60, :in)
        ]
      ),
      packages: [package_1]
    )
  end

  let(:pallet_2) do
    FactoryBot.build(
      :physical_structure,
      id: "pallet 2",
      container: FactoryBot.build(
        :physical_pallet,
        dimensions: [
          Measured::Length(48, :in),
          Measured::Length(40, :in),
          Measured::Length(48, :in)
        ]
      ),
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
      ]
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
      ]
    )
  end

  it "serializes one handling unit per structure with nested Items" do
    is_expected.to eq(
      [
        {
          UnitType: "PLT",
          Dimensions: [{
            Count: 1,
            Length: "48.0",
            Width: "40.0",
            Height: "60.0"
          }],
          Items: [{
            IsHazmat: false,
            Pieces: 1,
            PackageType: "BOX",
            NMFCItemNumber: "87700",
            NMFCSubNumber: "07",
            Class: "92.5",
            Weight: 11,
            Description: "Tumblers"
          }]
        },
        {
          UnitType: "SKD",
          Dimensions: [{
            Count: 1,
            Length: "48.0",
            Width: "40.0",
            Height: "48.0"
          }],
          Items: [{
            IsHazmat: false,
            Pieces: 1,
            PackageType: "BOX",
            NMFCItemNumber: "87700",
            NMFCSubNumber: "07",
            Class: "92.5",
            Weight: 2,
            Description: "Wicks"
          }]
        }
      ]
    )
  end

  context "when a structure has zero dimensions" do
    let(:pallet_1) do
      FactoryBot.build(
        :physical_structure,
        id: "pallet 1",
        container: FactoryBot.build(
          :physical_pallet,
          dimensions: [
            Measured::Length(0, :in),
            Measured::Length(0, :in),
            Measured::Length(0, :in)
          ]
        ),
        packages: [package_1]
      )
    end

    it "omits the Dimensions key for that handling unit" do
      expect(subject.first).not_to have_key(:Dimensions)
      expect(subject.first[:UnitType]).to eq("PLT")
    end
  end
end
