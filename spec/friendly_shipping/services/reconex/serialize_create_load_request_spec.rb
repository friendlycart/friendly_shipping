# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::SerializeCreateLoadRequest do
  subject(:call) { described_class.call(shipment: shipment, options: options) }

  let(:shipment) { Physical::Shipment.new(structures: structures, origin: origin, destination: destination) }

  let(:origin) do
    Physical::Location.new(
      company_name: "Widgets Inc.",
      name: "The Shipping Department",
      address1: "1910 S McCarran Blvd",
      city: "Reno",
      zip: "89502",
      region: "NV",
      country: "US",
      phone: "888-973-0223",
      email: "support@widgets.com"
    )
  end

  let(:destination) do
    Physical::Location.new(
      company_name: "ACME Inc.",
      name: "John Smith",
      address1: "813 Kincross Dr",
      city: "Boulder",
      zip: "80501",
      region: "CO",
      country: "US",
      phone: "3366682999",
      email: "john@acme.com"
    )
  end

  let(:billing_location) do
    Physical::Location.new(
      company_name: "Widgets Inc.",
      name: "Billing Dept",
      address1: "1247 Person St",
      city: "Durham",
      zip: "27703",
      region: "NC",
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
    FriendlyShipping::Services::Reconex::LoadOptions.new(
      account_id: 1140,
      scac: "UPGF",
      rate: true,
      pro_number_requested: true,
      dispatch: true,
      error_email: "errors@widgets.com",
      po_number: "H123456789",
      custom_id: "R987654321",
      billing_location: billing_location,
      dock_type: "BusinessWithDock",
      destination_dock_type: "BusinessWithOutDock",
      origin_notes: "Origin notes",
      origin_dock_open: Time.parse("2025-07-25T15:00:00Z"),
      origin_dock_close: Time.parse("2025-07-25T16:30:00Z"),
      origin_appointment: false,
      origin_freight_ready_time: Time.parse("2025-07-25T15:00:00Z"),
      destination_notes: "Destination notes",
      accessorials: {
        destination_liftgate: true,
        origin_inside_pickup: true
      },
      pickup_date: Time.parse("2025-07-25T13:58:30Z"),
      special_instructions: "Special instructions",
      shipping_quantity: 1,
      load_equipment_type: "VanStandardTrailer",
      shipping_units: "Pallets",
      all_stackable: true,
      load_notes: "Load notes",
      asn_needed: true,
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
        sub_class: "01",
        packaging: "Pallets",
        description: "Golden Brands 464 Soy Wax"
      )
    ]
  end

  describe "action" do
    subject(:action) { call[:action] }

    it { is_expected.to include(accountId: 1140) }
    it { is_expected.to include(rate: true) }
    it { is_expected.to include(book: "UPGF") }
    it { is_expected.to include(proNumber: true) }
    it { is_expected.to include(dispatch: true) }
    it { is_expected.to include(errorEmailNotification: "errors@widgets.com") }
  end

  describe "loadDetails" do
    subject(:load_details) { call[:loadDetails] }

    it { is_expected.to include(poNumber: "H123456789") }
    it { is_expected.to include(customID: "R987654321") }
    it { is_expected.not_to have_key(:customerBilling) }
  end

  describe "billingLocation" do
    subject(:billing) { call[:billingLocation] }

    it { is_expected.to include(name: "Widgets Inc.") }
    it { is_expected.to include(street: "1247 Person St") }
    it { is_expected.to include(city: "Durham") }
    it { is_expected.to include(stateProvince: "NC") }
    it { is_expected.to include(postalCode: "27703") }
    it { is_expected.to include(country: "US") }
  end

  describe "originLocation" do
    subject(:origin_location) { call[:originLocation] }

    it { is_expected.to include(name: "Widgets Inc.") }
    it { is_expected.to include(contact: "The Shipping Department") }
    it { is_expected.to include(street: "1910 S McCarran Blvd") }
    it { is_expected.to include(city: "Reno") }
    it { is_expected.to include(stateProvince: "NV") }
    it { is_expected.to include(postalCode: "89502") }
    it { is_expected.to include(country: "US") }
    it { is_expected.to include(phone: "888-973-0223") }
    it { is_expected.to include(email: "support@widgets.com") }
    it { is_expected.to include(dockType: "BusinessWithDock") }
    it { is_expected.to include(notes: "Origin notes") }
    it { is_expected.to include(appointment: false) }

    it "serializes dock open time" do
      expect(origin_location[:dockOpen]).to eq("2025-07-25T15:00:00Z")
    end

    it "serializes dock close time" do
      expect(origin_location[:dockClose]).to eq("2025-07-25T16:30:00Z")
    end

    it "serializes freight ready time" do
      expect(origin_location[:freightReadyTime]).to eq("2025-07-25T15:00:00Z")
    end
  end

  describe "destinationLocation" do
    subject(:destination_location) { call[:destinationLocation] }

    it { is_expected.to include(name: "ACME Inc.") }
    it { is_expected.to include(contact: "John Smith") }
    it { is_expected.to include(street: "813 Kincross Dr") }
    it { is_expected.to include(city: "Boulder") }
    it { is_expected.to include(stateProvince: "CO") }
    it { is_expected.to include(postalCode: "80501") }
    it { is_expected.to include(country: "US") }
    it { is_expected.to include(phone: "3366682999") }
    it { is_expected.to include(email: "john@acme.com") }
    it { is_expected.to include(dockType: "BusinessWithOutDock") }
    it { is_expected.to include(notes: "Destination notes") }
    it { is_expected.to include(appointment: false) }
  end

  describe "accessorials" do
    subject(:accessorials) { call[:accessorials] }

    it "converts keys to camelCase" do
      expect(accessorials).to eq(
        "destinationLiftgate" => true,
        "originInsidePickup" => true
      )
    end
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
      expect(item[:subClass]).to eq("01")
      expect(item[:description]).to eq("Golden Brands 464 Soy Wax")
    end

    it "includes hazMat" do
      expect(items.first[:hazMat]).to eq(isHazMat: false)
    end

    it "serializes item dimensions with shipQuantity" do
      dimensions = items.first[:itemDimensions]
      expect(dimensions[:length]).to eq(16)
      expect(dimensions[:height]).to eq(13)
      expect(dimensions[:width]).to eq(14)
      expect(dimensions[:shipQuantity]).to eq(1)
    end
  end

  describe "additionalLoadInfo" do
    subject(:additional_info) { call[:additionalLoadInfo] }

    it { is_expected.to include(specialInstructions: "Special instructions") }
    it { is_expected.to include(shippingQuantity: 1) }
    it { is_expected.to include(loadEquipmentType: "VanStandardTrailer") }
    it { is_expected.to include(shippingUnits: "Pallets") }
    it { is_expected.to include(allStackable: true) }
    it { is_expected.to include(loadNotes: "Load notes") }
    it { is_expected.to include(asn: { isASNNeeded: true }) }

    it "serializes pickup date" do
      expect(additional_info[:pickedUpDate]).to eq("2025-07-25T13:58:30Z")
    end

    it "omits must arrive by date when nil" do
      expect(additional_info).not_to have_key(:mustArriveByDate)
    end
  end

  context "when billing_location is nil" do
    let(:options) do
      FriendlyShipping::Services::Reconex::LoadOptions.new(
        account_id: 1140,
        scac: "UPGF",
        structure_options: structure_options
      )
    end

    it "omits billingLocation" do
      expect(call).not_to have_key(:billingLocation)
    end
  end
end
