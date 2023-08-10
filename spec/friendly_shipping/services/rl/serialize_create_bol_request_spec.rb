# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::SerializeCreateBOLRequest do
  subject { described_class.call(shipment: shipment, options: options) }

  let(:shipment) do
    FactoryBot.build(
      :physical_shipment,
      origin: origin,
      destination: destination,
      packages: [package_1, package_2]
    )
  end

  let(:pickup_time_window) do
    Time.parse("2023-08-01 09:00:00 UTC")..Time.parse("2023-08-01 17:00:00 UTC")
  end

  let(:options) do
    FriendlyShipping::Services::RL::BOLOptions.new(
      pickup_time_window: pickup_time_window,
      additional_service_codes: %w[OriginLiftgate],
      generate_universal_pro: true,
      package_options: [
        FriendlyShipping::Services::RL::PackageOptions.new(
          package_id: "package 1",
          item_options: [
            FriendlyShipping::Services::RL::ItemOptions.new(
              item_id: "item 1",
              nmfc_primary_code: "87700",
              nmfc_sub_code: "07",
              freight_class: "92.5"
            )
          ]
        ),
        FriendlyShipping::Services::RL::PackageOptions.new(
          package_id: "package 2",
          item_options: [
            FriendlyShipping::Services::RL::ItemOptions.new(
              item_id: "item 2",
              nmfc_primary_code: "87700",
              nmfc_sub_code: "07",
              freight_class: "92.5"
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
    FactoryBot.build(:physical_box)
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
      company_name: "ACME Inc",
      address1: "123 Maple St",
      address2: "Suite 100",
      city: "New York",
      region: "NY",
      zip: "10001",
      phone: "123-123-1234",
      email: "acme@example.com"
    )
  end

  let(:destination) do
    FactoryBot.build(
      :physical_location,
      company_name: "Widgets LLC",
      address1: "456 Oak St",
      address2: "Suite 200",
      city: "Boulder",
      region: "CO",
      zip: "80301",
      phone: "321-321-3210",
      email: "widgets@example.com"
    )
  end

  let(:serialized_packages) do
    options.packages_serializer.call(packages: shipment.packages, options: options)
  end

  it do
    is_expected.to eq(
      {
        BillOfLading: {
          BOLDate: Time.now.strftime('%m/%d/%Y'),
          Shipper: {
            CompanyName: "ACME Inc",
            AddressLine1: "123 Maple St",
            AddressLine2: "Suite 100",
            City: "New York",
            StateOrProvince: "NY",
            ZipOrPostalCode: "10001",
            CountryCode: "USA",
            PhoneNumber: "123-123-1234",
            EmailAddress: "acme@example.com"
          },
          Consignee: {
            CompanyName: "Widgets LLC",
            AddressLine1: "456 Oak St",
            AddressLine2: "Suite 200",
            City: "Boulder",
            StateOrProvince: "CO",
            ZipOrPostalCode: "80301",
            CountryCode: "USA",
            PhoneNumber: "321-321-3210",
            EmailAddress: "widgets@example.com"
          },
          BillTo: {
            CompanyName: "ACME Inc",
            AddressLine1: "123 Maple St",
            AddressLine2: "Suite 100",
            City: "New York",
            StateOrProvince: "NY",
            ZipOrPostalCode: "10001",
            CountryCode: "USA",
            PhoneNumber: "123-123-1234",
            EmailAddress: "acme@example.com"
          },
          Items: serialized_packages,
          AdditionalServices: %w[OriginLiftgate]
        },
        PickupRequest: {
          PickupInformation: {
            PickupDate: "08/01/2023",
            ReadyTime: "09:00 AM",
            CloseTime: "05:00 PM"
          }
        },
        GenerateUniversalPro: true
      }
    )
  end

  context "when pickup time window is not provided" do
    let(:pickup_time_window) { nil }

    it { is_expected.to_not have_key(:PickupRequest) }
  end
end
