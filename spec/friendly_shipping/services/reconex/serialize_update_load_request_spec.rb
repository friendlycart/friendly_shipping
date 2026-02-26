# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::SerializeUpdateLoadRequest do
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
    FriendlyShipping::Services::Reconex::UpdateLoadOptions.new(
      load_id: 3_310_514,
      account_id: 1140,
      scac: "UPGF",
      dispatch: true,
      billing_id: "2223606199",
      pro_number: "123456789",
      po_number: "H123456789",
      custom_id: "R987654321",
      email_from: "shipping@widgets.com",
      email_to: "carrier@freight.com",
      email_subject: "BOL Dispatch",
      email_body: "Please dispatch this load.",
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

  describe "action" do
    subject(:action) { call[:action] }

    it { is_expected.to include(loadId: 3_310_514) }
    it { is_expected.to include(accountId: 1140) }
    it { is_expected.to include(book: "UPGF") }
    it { is_expected.to include(dispatch: true) }
  end

  describe "loadDetails" do
    subject(:load_details) { call[:loadDetails] }

    it { is_expected.to include(billingID: "2223606199") }
    it { is_expected.to include(proNumber: "123456789") }
    it { is_expected.to include(poNumber: "H123456789") }
    it { is_expected.to include(customID: "R987654321") }
  end

  describe "emailParameters" do
    subject(:email_params) { call[:emailParameters] }

    it { is_expected.to include(emailFrom: "shipping@widgets.com") }
    it { is_expected.to include(emailTo: "carrier@freight.com") }
    it { is_expected.to include(emailSubject: "BOL Dispatch") }
    it { is_expected.to include(emailBody: "Please dispatch this load.") }
  end

  context "when email parameters are nil" do
    let(:options) do
      FriendlyShipping::Services::Reconex::UpdateLoadOptions.new(
        load_id: 3_310_514,
        account_id: 1140,
        structure_options: structure_options
      )
    end

    it "omits emailParameters" do
      expect(call).not_to have_key(:emailParameters)
    end
  end

  context "when scac is nil" do
    let(:options) do
      FriendlyShipping::Services::Reconex::UpdateLoadOptions.new(
        load_id: 3_310_514,
        account_id: 1140,
        dispatch: true,
        structure_options: structure_options
      )
    end

    it "omits book from action" do
      expect(call[:action]).not_to have_key(:book)
    end
  end
end
