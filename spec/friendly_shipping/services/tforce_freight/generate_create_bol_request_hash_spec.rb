# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::GenerateCreateBOLRequestHash do
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
        description: "Can of Socks",
        weight: Measured::Weight(500, :lbs),
        dimensions: [
          Measured::Length(9.874, :in),
          Measured::Length(12.906, :in),
          Measured::Length(5.811, :in)
        ]
      )
    end

    let(:options) do
      FriendlyShipping::Services::TForceFreight::BOLOptions.new(
        pickup_at: Time.parse("2023-05-18 12:30:00"),
        pickup_options: %w[INPU LIFO],
        delivery_options: %w[INDE LIFD],
        pickup_instructions: "East Dock",
        handling_instructions: "Handle with care",
        delivery_instructions: "West Dock",
        reference_numbers: [
          { code: :bill_of_lading_number, value: "123" },
          { code: :purchase_order_number, value: "456" }
        ],
        document_options: document_options,
        package_options: package_options
      )
    end

    let(:document_options) do
      [
        FriendlyShipping::Services::TForceFreight::DocumentOptions.new(
          type: :tforce_bol
        ),
        FriendlyShipping::Services::TForceFreight::DocumentOptions.new(
          type: :label,
          thermal: true,
          number_of_stickers: 2
        )
      ]
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
        FriendlyShipping::Services::TForceFreight::RatesItemOptions.new(
          item_id: "item_one",
          packaging: :pallet,
          freight_class: "92.5",
          nmfc_primary_code: "16030",
          nmfc_sub_code: "01"
        )
      ]
    end

    describe "keys" do
      subject(:keys) { call.keys }

      it do
        is_expected.to eq(
          %i[
            requestOptions
            shipFrom
            shipTo
            payment
            commodities
            instructions
            serviceOptions
            pickupRequest
            documents
            handlingUnitOne
            references
          ]
        )
      end
    end

    describe "requestOptions" do
      subject(:request_options) { call[:requestOptions] }

      it do
        is_expected.to eq(
          pickupDate: "2023-05-18",
          serviceCode: "308",
          previewRate: false,
          timeInTransit: false
        )
      end
    end

    describe "shipFrom" do
      subject(:ship_from) { call[:shipFrom] }

      it do
        is_expected.to eq(
          name: "ACME Inc",
          contact: "John Smith",
          email: "john@acme.com",
          phone: {
            number: "123-123-1234"
          },
          address: {
            addressLine: "123 Maple St Suite 456",
            stateProvinceCode: "VA",
            city: "Richmond",
            postalCode: "23224",
            country: "US"
          },
          isResidential: false
        )
      end
    end

    describe "shipTo" do
      subject(:ship_to) { call[:shipTo] }

      it do
        is_expected.to eq(
          name: "Widgets LLC",
          contact: "Jane Doe",
          email: "jane@widgets.com",
          phone: {
            number: "456-456-4567"
          },
          address: {
            addressLine: "123 Oak Ave Suite 456",
            stateProvinceCode: "MO",
            city: "Allanton",
            postalCode: "63025",
            country: "US"
          },
          isResidential: false
        )
      end
    end

    describe "payment" do
      subject(:payment) { call[:payment] }

      it do
        is_expected.to eq(
          {
            payer: {
              name: "ACME Inc",
              contact: "John Smith",
              email: "john@acme.com",
              phone: {
                number: "123-123-1234"
              },
              address: {
                addressLine: "123 Maple St Suite 456",
                stateProvinceCode: "VA",
                city: "Richmond",
                postalCode: "23224",
                country: "US"
              },
            },
            billingCode: "10"
          }
        )
      end
    end

    describe "handlingUnitOne" do
      subject(:handling_unit_one) { call[:handlingUnitOne] }

      it do
        is_expected.to eq(
          {
            quantity: 1,
            typeCode: "PLT"
          }
        )
      end
    end

    describe "handlingUnitTwo" do
      subject(:handling_unit_two) { call[:handlingUnitTwo] }

      it { is_expected.to be_nil }
    end

    describe "commodities" do
      subject(:commodities) { call[:commodities] }

      it do
        is_expected.to eq(
          [
            {
              description: "Can of Socks",
              class: "92.5",
              nmfc: {
                prime: "16030",
                sub: "01"
              },
              pieces: 1,
              weight: {
                weight: 500,
                weightUnit: "LBS"
              },
              packagingType: "PLT",
              dangerousGoods: false,
              dimensions: {
                length: 9.87,
                width: 12.91,
                height: 5.81,
                unit: "IN"
              }
            }
          ]
        )
      end
    end

    describe "references" do
      subject(:references) { call[:references] }

      it do
        is_expected.to eq(
          [
            { number: "123", type: "BL" },
            { number: "456", type: "PO" }
          ]
        )
      end
    end

    describe "instructions" do
      subject(:instructions) { call[:instructions] }

      it do
        is_expected.to eq(
          {
            delivery: "West Dock",
            handling: "Handle with care",
            pickup: "East Dock"
          }
        )
      end
    end

    describe "serviceOptions" do
      subject(:service_options) { call[:serviceOptions] }

      it do
        is_expected.to eq(
          {
            pickup: %w[INPU LIFO],
            delivery: %w[INDE LIFD]
          }
        )
      end
    end

    describe "pickupRequest" do
      subject(:pickup_request) { call[:pickupRequest] }

      it do
        is_expected.to eq(
          {
            pickup: {
              date: "2023-05-18",
              time: "12:30:00",
              openTime: "00:00:00",
              closeTime: "23:59:59"
            },
            requester: {
              companyName: "ACME Inc",
              contactName: "John Smith",
              email: "john@acme.com",
              phone: {
                number: "123-123-1234"
              }
            },
            pomIndicator: false
          }
        )
      end
    end

    describe "documents" do
      subject(:documents) { call[:documents] }

      it do
        is_expected.to eq(
          {
            image: [
              {
                type: "20",
                format: "01",
                label: {
                  type: "01",
                  startPosition: 1,
                  numberOfStickers: 1
                }
              }, {
                type: "30",
                format: "01",
                label: {
                  type: "02",
                  startPosition: 1,
                  numberOfStickers: 2
                }
              }
            ]
          }
        )
      end
    end
  end
end
