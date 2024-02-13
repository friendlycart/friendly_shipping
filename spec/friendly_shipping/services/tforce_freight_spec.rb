# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/tforce_freight'

RSpec.describe FriendlyShipping::Services::TForceFreight do
  subject(:service) { described_class.new(access_token: access_token, test: true) }

  let(:access_token) do
    FriendlyShipping::Services::TForceFreight::AccessToken.new(
      token_type: "Bearer",
      expires_in: 3599,
      ext_expires_in: 3599,
      raw_token: "secret_token"
    )
  end

  describe "#carriers" do
    subject(:carriers) { service.carriers.value! }

    it "has only one carrier with four shipping methods" do
      expect(carriers.length).to eq(1)
      expect(carriers.first.shipping_methods.map(&:service_code)).to contain_exactly(
        "308", "309", "334", "349"
      )
      expect(carriers.first.shipping_methods.map(&:name)).to contain_exactly(
        "TForce Freight LTL",
        "TForce Freight LTL - Guaranteed",
        "TForce Freight LTL - Guaranteed A.M.",
        "TForce Standard LTL",
      )
    end
  end

  describe "#create_access_token" do
    subject(:create_access_token) do
      service.create_access_token(
        token_endpoint: "https://example.com",
        client_id: "client-id",
        client_secret: "client-secret",
        scope: "read"
      )
    end

    let(:response) do
      instance_double(
        RestClient::Response,
        code: 200,
        body: %({
          "token_type": "Bearer",
          "expires_in": 3599,
          "ext_expires_in": 3599,
          "access_token": "XYADfw4Hz2KdN_sd8N4TzMo9"
        }),
        headers: {
          "Cache-Control" => "no-store, no-cache",
          "Content-Type" => "application/json; charset=utf-8"
        }
      )
    end

    before do
      expect(RestClient).to receive(:post).with(
        "https://example.com",
        "client_id=client-id&client_secret=client-secret&grant_type=client_credentials&scope=read",
        { Accept: "application/json", Content_Type: "application/x-www-form-urlencoded" }
      ).and_return(response)
    end

    it "makes API request and returns access token" do
      result = create_access_token
      expect(result).to be_success
      expect(result.value!).to be_a(FriendlyShipping::ApiResult)

      access_token = result.value!.data
      expect(access_token).to be_a(FriendlyShipping::Services::TForceFreight::AccessToken)
      expect(access_token.token_type).to eq("Bearer")
      expect(access_token.expires_in).to eq(3599)
      expect(access_token.ext_expires_in).to eq(3599)
      expect(access_token.raw_token).to eq("XYADfw4Hz2KdN_sd8N4TzMo9")
    end
  end

  describe "#rates" do
    subject(:rates) { service.rates(shipment, options: options) }

    let(:shipment) { Physical::Shipment.new(packages: packages, origin: origin, destination: destination) }

    let(:origin) do
      Physical::Location.new(
        city: "Richmond",
        zip: "23224",
        region: "VA",
        country: "US"
      )
    end

    let(:destination) do
      Physical::Location.new(
        city: "Eureka",
        zip: "63025",
        region: "MO",
        country: "US"
      )
    end

    let(:packages) { [package_one, package_two] }

    let(:package_one) do
      Physical::Package.new(
        id: "my_package_1",
        items: [item_one]
      )
    end

    let(:package_two) do
      Physical::Package.new(
        id: "my_package_2",
        items: [item_two]
      )
    end

    let(:item_one) do
      Physical::Item.new(
        id: "item_one",
        weight: Measured::Weight(500, :lbs)
      )
    end

    let(:item_two) do
      Physical::Item.new(
        id: "item_two",
        weight: Measured::Weight(500, :lbs)
      )
    end

    let(:options) do
      FriendlyShipping::Services::TForceFreight::RatesOptions.new(
        pickup_date: Date.today,
        shipping_method: FriendlyShipping::ShippingMethod.new(service_code: "308"),
        billing_address: billing_location,
        customer_context: customer_context,
        package_options: package_options
      )
    end

    let(:customer_context) { "order-12345" }

    let(:billing_location) do
      Physical::Location.new(
        city: "Durham",
        zip: "27703",
        region: "NC",
        country: "US"
      )
    end

    let(:package_options) do
      [
        FriendlyShipping::Services::TForceFreight::RatesPackageOptions.new(
          package_id: package_one.id,
          item_options: item_one_options
        ),
        FriendlyShipping::Services::TForceFreight::RatesPackageOptions.new(
          package_id: package_two.id,
          item_options: item_two_options
        )
      ]
    end

    let(:item_one_options) do
      [
        FriendlyShipping::Services::TForceFreight::RatesItemOptions.new(
          item_id: "item_one",
          packaging: :carton,
          freight_class: "92.5",
          nmfc_primary_code: "16030",
          nmfc_sub_code: "1"
        )
      ]
    end

    let(:item_two_options) do
      [
        FriendlyShipping::Services::TForceFreight::RatesItemOptions.new(
          item_id: "item_two",
          packaging: :pallet,
          freight_class: "92.5",
          nmfc_primary_code: "16030",
          nmfc_sub_code: "1"
        )
      ]
    end

    context "with a valid request", vcr: { cassette_name: "tforce_freight/rates/success" } do
      it { is_expected.to be_success }

      it "has all the right data" do
        result = rates.value!.data
        expect(result.length).to eq(3)
        rate = result.first
        expect(rate).to be_a(FriendlyShipping::Rate)
        expect(rate.total_amount).to eq(Money.new(157_356, "USD"))
        expect(rate.shipping_method.name).to eq("TForce Freight LTL")
        expect(rate.data[:days_in_transit]).to eq(3)
      end
    end

    context "with a missing destination postal code", vcr: { cassette_name: "tforce_freight/rates/failure" } do
      let(:destination) do
        Physical::Location.new(
          company_name: "Consignee Test 1",
          city: "Allanton",
          region: "MO",
          country: "US"
        )
      end

      it { is_expected.to be_failure }

      it "has the correct error message" do
        expect(rates.failure.to_s).to include("Invalid type. Expected String but got Null.")
      end
    end
  end

  it { is_expected.to respond_to(:rate_estimates) }

  describe "#create_pickup" do
    subject(:create_pickup) { service.create_pickup(shipment, options: options) }

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

    let(:packages) { [package_one, package_two] }

    let(:package_one) do
      Physical::Package.new(
        id: "my_package_1",
        items: [item_one]
      )
    end

    let(:package_two) do
      Physical::Package.new(
        id: "my_package_2",
        items: [item_two]
      )
    end

    let(:item_one) do
      Physical::Item.new(
        id: "item_one",
        weight: Measured::Weight(500, :lbs)
      )
    end

    let(:item_two) do
      Physical::Item.new(
        id: "item_two",
        weight: Measured::Weight(500, :lbs)
      )
    end

    let(:options) do
      FriendlyShipping::Services::TForceFreight::PickupOptions.new(
        pickup_time_window: Time.parse("2024-01-22 08:00:00")..Time.parse("2024-01-22 16:00:00"),
        pickup_at: Time.parse("2024-01-22 12:30:00"),
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
        ),
        FriendlyShipping::Services::TForceFreight::RatesPackageOptions.new(
          package_id: package_two.id,
          item_options: item_two_options
        )
      ]
    end

    let(:item_one_options) do
      [
        FriendlyShipping::Services::TForceFreight::RatesItemOptions.new(
          item_id: "item_one",
          packaging: :carton
        )
      ]
    end

    let(:item_two_options) do
      [
        FriendlyShipping::Services::TForceFreight::RatesItemOptions.new(
          item_id: "item_two",
          packaging: :pallet
        )
      ]
    end

    context "with a valid request", vcr: { cassette_name: "tforce_freight/create_pickup/success" } do
      it { is_expected.to be_success }

      it "has all the right data" do
        result = create_pickup.value!.data
        expect(result).to eq(
          confirmation_number: "WBU5337790",
          destination_is_rural: "false",
          email_sent: "false",
          origin_is_rural: "false",
          response_status_code: "1",
          response_status_description: "Success",
          transaction_id: "7acf9c09-55f0-41a4-9371-9caafd63d618"
        )
      end
    end

    context "with a missing destination postal code", vcr: { cassette_name: "tforce_freight/create_pickup/failure" } do
      let(:destination) { Physical::Location.new }

      it { is_expected.to be_failure }

      it "has the correct error message" do
        expect(create_pickup.failure.to_s).to include("Invalid type. Expected String but got Null.")
      end
    end
  end

  describe "#create_bol" do
    subject(:create_bol) { service.create_bol(shipment, options: options) }

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

    let(:packages) { [package_one, package_two] }

    let(:package_one) do
      Physical::Package.new(
        id: "my_package_1",
        items: [item_one]
      )
    end

    let(:package_two) do
      Physical::Package.new(
        id: "my_package_2",
        items: [item_two]
      )
    end

    let(:item_one) do
      Physical::Item.new(
        id: "item_one",
        weight: Measured::Weight(500, :lbs),
        description: "Widgets"
      )
    end

    let(:item_two) do
      Physical::Item.new(
        id: "item_two",
        weight: Measured::Weight(500, :lbs),
        description: "Gadgets"
      )
    end

    let(:options) do
      FriendlyShipping::Services::TForceFreight::BOLOptions.new(
        pickup_at: Time.parse("2024-01-22 12:30:00"),
        pickup_time_window: Time.parse("2024-01-22 08:00:00")..Time.parse("2024-01-22 16:00:00"),
        delivery_options: %w[INDE LIFD],
        pickup_instructions: "East Dock",
        handling_instructions: "Handle with care",
        delivery_instructions: "West Dock",
        package_options: package_options,
        reference_numbers: [
          { code: :bill_of_lading_number, value: "123" },
          { code: :purchase_order_number, value: "456" }
        ],
        document_options: document_options
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
        ),
        FriendlyShipping::Services::TForceFreight::RatesPackageOptions.new(
          package_id: package_two.id,
          item_options: item_two_options
        )
      ]
    end

    let(:item_one_options) do
      [
        FriendlyShipping::Services::TForceFreight::RatesItemOptions.new(
          item_id: "item_one",
          packaging: :carton,
          freight_class: "92.5",
          nmfc_primary_code: "16030",
          nmfc_sub_code: "1"
        )
      ]
    end

    let(:item_two_options) do
      [
        FriendlyShipping::Services::TForceFreight::RatesItemOptions.new(
          item_id: "item_two",
          packaging: :pallet,
          freight_class: "92.5",
          nmfc_primary_code: "16030",
          nmfc_sub_code: "1"
        )
      ]
    end

    context "with a valid request", vcr: { cassette_name: "tforce_freight/create_bol/success" } do
      it { is_expected.to be_success }

      it "has all the right data" do
        result = create_bol.value!.data
        expect(result).to be_a(FriendlyShipping::Services::TForceFreight::ShipmentInformation)
        expect(result.bol_id).to eq(46_178_022)
        expect(result.pro_number).to eq("090509075")

        expect(result.documents).to be_a(Array)
        expect(result.documents.size).to eq(2)

        document = result.documents[0]
        expect(document.document_type).to eq(:tforce_bol)
        expect(document.document_format).to eq(:pdf)
        expect(document.binary).to start_with("%PDF-")
        expect(document.status).to eq("NFO")

        document = result.documents[1]
        expect(document.document_type).to eq(:label)
        expect(document.document_format).to eq(:pdf)
        expect(document.binary).to start_with("%PDF-")
        expect(document.status).to eq("NFO")
      end
    end

    context "with a missing destination postal code", vcr: { cassette_name: "tforce_freight/create_bol/failure" } do
      let(:destination) { Physical::Location.new }

      it { is_expected.to be_failure }

      it "has the correct error message" do
        expect(create_bol.failure.to_s).to include("Required properties are missing from object: name")
      end
    end
  end
end
