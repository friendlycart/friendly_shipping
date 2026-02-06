# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::SerializeQuoteRequest do
  subject(:call) { described_class.call(shipment: shipment, options: options) }

  let(:shipment) { Physical::Shipment.new(structures: structures, origin: origin, destination: destination) }

  let(:origin) do
    Physical::Location.new(
      address1: "1910 S McCarran Blvd",
      city: "Reno",
      zip: "89502",
      region: "NV",
      country: "US"
    )
  end

  let(:destination) do
    Physical::Location.new(
      address1: "813 Kincross Dr",
      city: "Boulder",
      zip: "80501",
      region: "CO",
      country: "US"
    )
  end

  let(:structures) { [structure] }

  let(:structure) do
    Physical::Structure.new(
      id: "structure_1",
      packages: [package]
    )
  end

  let(:package) do
    Physical::Package.new(
      id: "package_1",
      items: [item],
      dimensions: [
        Measured::Length(16, :in),
        Measured::Length(14, :in),
        Measured::Length(13, :in)
      ]
    )
  end

  let(:item) do
    Physical::Item.new(
      id: "item_1",
      weight: Measured::Weight(46.5, :lb)
    )
  end

  let(:options) do
    FriendlyShipping::Services::Reconex::QuoteOptions.new(
      must_arrive_by_date: Time.parse("2025-07-25T13:58:30Z"),
      dock_type: "BusinessWithDock",
      total_quantity: "1",
      total_units: "Pallets",
      accessorials: {
        destination_liftgate: true,
        origin_inside_pickup: false
      },
      structure_options: structure_options
    )
  end

  let(:structure_options) do
    [
      FriendlyShipping::Services::Reconex::StructureOptions.new(
        structure_id: "structure_1",
        package_options: package_options
      )
    ]
  end

  let(:package_options) do
    [
      FriendlyShipping::Services::Reconex::PackageOptions.new(
        package_id: "package_1",
        freight_class: "70",
        nmfc_code: "199620",
        packaging: "Pallets",
        description: "Golden Brands 464 Soy Wax"
      )
    ]
  end

  it "serializes the must arrive by date" do
    expect(call[:mustArriveByDate]).to eq("2025-07-25T13:58:30Z")
  end

  describe "originLocation" do
    subject(:origin_location) { call[:originLocation] }

    it { is_expected.to include(street: "1910 S McCarran Blvd") }
    it { is_expected.to include(city: "Reno") }
    it { is_expected.to include(state: "NV") }
    it { is_expected.to include(postalCode: "89502") }
    it { is_expected.to include(country: "US") }
    it { is_expected.to include(dockType: "BusinessWithDock") }
  end

  describe "destinationLocation" do
    subject(:destination_location) { call[:destinationLocation] }

    it { is_expected.to include(street: "813 Kincross Dr") }
    it { is_expected.to include(city: "Boulder") }
    it { is_expected.to include(state: "CO") }
    it { is_expected.to include(postalCode: "80501") }
    it { is_expected.to include(country: "US") }
    it { is_expected.to include(dockType: "BusinessWithDock") }
  end

  describe "items" do
    subject(:items) { call[:items] }

    it "has one item" do
      expect(items.length).to eq(1)
    end

    it "serializes item fields" do
      item = items.first
      expect(item[:qty]).to eq("1")
      expect(item[:packaging]).to eq("Pallets")
      expect(item[:freightClass]).to eq("70")
      expect(item[:weight]).to eq("46.5")
      expect(item[:nmfCnumber]).to eq("199620")
      expect(item[:description]).to eq("Golden Brands 464 Soy Wax")
    end

    it "serializes item dimensions" do
      dimensions = items.first[:itemDimensions]
      expect(dimensions[:length]).to eq(16)
      expect(dimensions[:width]).to eq(14)
      expect(dimensions[:height]).to eq(13)
    end
  end

  describe "totalDetail" do
    subject(:total_detail) { call[:totalDetail] }

    it { is_expected.to include(quantity: "1") }
    it { is_expected.to include(units: "Pallets") }
  end

  describe "accessorials" do
    subject(:accessorials) { call[:accessorials] }

    it "converts keys to camelCase" do
      expect(accessorials).to eq(
        "destinationLiftgate" => true,
        "originInsidePickup" => false
      )
    end
  end

  context "when must_arrive_by_date is nil" do
    let(:options) do
      FriendlyShipping::Services::Reconex::QuoteOptions.new(
        structure_options: structure_options
      )
    end

    it "serializes mustArriveByDate as nil" do
      expect(call[:mustArriveByDate]).to be_nil
    end
  end
end
