# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::GeneratePickupRequestHash do
  describe ".call" do
    subject(:call) { described_class.call(shipment: shipment, options: options) }

    let(:shipment) { Physical::Shipment.new(packages: packages, origin: origin, destination: destination) }

    let(:origin) do
      Physical::Location.new(
        company_name: "ACME Inc",
        name: "John Smith",
        email: "john@acme.com",
        phone: "123-123-1234",
        address1: "123 Maple St",
        address2: "Suite 456",
        city: "Richmond",
        zip: "23224",
        region: "VA",
        country: "US"
      )
    end

    let(:destination) do
      Physical::Location.new(
        company_name: "Widgets LLC",
        name: "Jane Doe",
        email: "jane@widgets.com",
        phone: "456-456-4567",
        address1: "123 Oak Ave",
        address2: "Suite 456",
        city: "Allanton",
        zip: "63025",
        region: "MO",
        country: "US"
      )
    end

    let(:packages) { [package_one] }

    let(:package_one) do
      Physical::Package.new(
        id: "my_package_1",
        items: [item_one]
      )
    end

    let(:item_one) do
      Physical::Item.new(
        id: "item_one",
        weight: Measured::Weight(500, :lbs),
        description: "Can of Socks"
      )
    end

    let(:options) do
      FriendlyShipping::Services::TForceFreight::PickupOptions.new(
        pickup_time_window: Time.parse("2023-05-18 08:00:00")..Time.parse("2023-05-18 16:00:00"),
        pickup_at: Time.parse("2023-05-18 12:30:00"),
        service_options: %w[INPU LIFO],
        pickup_instructions: "East Dock",
        handling_instructions: "Handle with care",
        delivery_instructions: "West Dock",
        package_options: package_options
      )
    end

    let(:package_options) do
      [
        FriendlyShipping::Services::TForceFreight::RatesPackageOptions.new(
          package_id: package_one.id,
          item_options: item_one_options
        )
      ]
    end

    let(:item_one_options) do
      [
        FriendlyShipping::Services::TForceFreight::ItemOptions.new(
          item_id: "item_one",
          packaging: :pallet
        )
      ]
    end

    describe "keys" do
      subject(:keys) { call.keys }

      it do
        is_expected.to eq(
          %i[
            pickup
            requester
            origin
            destination
            services
            lineItems
            instructions
            pomIndicator
          ]
        )
      end
    end

    describe "pickup" do
      subject(:pickup) { call[:pickup] }

      it do
        is_expected.to eq(
          date: "2023-05-18",
          time: "12:30:00",
          openTime: "08:00:00",
          closeTime: "16:00:00"
        )
      end
    end

    describe "requester" do
      subject(:requester) { call[:requester] }

      it do
        is_expected.to eq(
          companyName: "ACME Inc",
          contactName: "John Smith",
          email: "john@acme.com",
          phone: {
            number: "123-123-1234"
          }
        )
      end
    end

    describe "origin" do
      subject(:origin_hash) { call[:origin] }

      it do
        is_expected.to eq(
          companyName: "ACME Inc",
          contactName: "John Smith",
          email: "john@acme.com",
          phone: {
            number: "123-123-1234"
          },
          address: {
            address1: "123 Maple St",
            address2: "Suite 456",
            city: "Richmond",
            country: "US",
            postalCode: "23224",
            stateProvinceCode: "VA"
          }
        )
      end
    end

    describe "destination" do
      subject(:destination_hash) { call[:destination] }

      it do
        is_expected.to eq(
          postalCode: "63025",
          country: "US"
        )
      end
    end

    describe "services" do
      subject(:services) { call[:services] }

      it { is_expected.to eq(%w[INPU LIFO]) }
    end

    describe "line_items" do
      subject(:line_items) { call[:lineItems] }

      it do
        is_expected.to eq(
          [
            {
              description: "Can of Socks",
              weight: 500,
              weightUnit: "LBS",
              pieces: 1,
              packagingType: "PLT",
              hazardous: false
            }
          ]
        )
      end
    end

    describe "instructions" do
      subject(:instructions) { call[:instructions] }

      it do
        is_expected.to eq(
          delivery: "West Dock",
          handling: "Handle with care",
          pickup: "East Dock"
        )
      end
    end

    describe "pomIndicator" do
      subject(:pom_indicator) { call[:pomIndicator] }

      it { is_expected.to be(false) }
    end
  end
end
