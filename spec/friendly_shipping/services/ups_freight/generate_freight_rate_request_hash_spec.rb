# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/generate_freight_rate_request_hash'
require 'friendly_shipping/services/ups_freight/rates_options'
require 'friendly_shipping/services/ups_freight/pickup_request_options'

RSpec.describe FriendlyShipping::Services::UpsFreight::GenerateFreightRateRequestHash do
  subject(:full_request) { JSON.parse(described_class.call(shipment: shipment, options: options).to_json) }

  let(:shipment) { Physical::Shipment.new(packages: packages, origin: origin, destination: destination) }

  let(:origin) do
    Physical::Location.new(
      company_name: 'Developer Test 1',
      address1: '01 Developer Way',
      city: 'Richmond',
      zip: '23224',
      region: 'VA',
      country: 'US'
    )
  end

  let(:destination) do
    Physical::Location.new(
      company_name: 'Consignee Test 1',
      address1: '000 Consignee Street',
      city: 'Allanton',
      zip: '63025',
      region: 'MO',
      country: 'US'
    )
  end

  let(:packages) { [package_one] }

  let(:package_one) do
    Physical::Package.new(
      id: 'my_package_1',
      items: [item_one]
    )
  end

  let(:item_one) do
    Physical::Item.new(
      id: 'item_one',
      weight: Measured::Weight(500, :lbs),
      description: 'Can of Socks'
    )
  end

  let(:options) do
    FriendlyShipping::Services::UpsFreight::RatesOptions.new(
      shipping_method: FriendlyShipping::ShippingMethod.new(service_code: '308'),
      shipper_number: 'xxx1234',
      billing_address: billing_location,
      customer_context: customer_context,
      package_options: package_options
    )
  end

  let(:customer_context) { 'order-12345' }

  let(:billing_location) do
    ::Physical::Location.new(
      name: "Donald Duck",
      company_name: "Duck Science",
      address1: "Duck Street",
      address2: "Duck Window 2",
      city: "Ducktown",
      zip: "54321",
      region: "NC",
      country: "US"
    )
  end

  let(:package_options) do
    [
      FriendlyShipping::Services::UpsFreight::RatesPackageOptions.new(
        package_id: package_one.id,
        handling_unit: handling_unit,
        item_options: item_one_options
      )
    ]
  end

  let(:item_one_options) do
    [
      FriendlyShipping::Services::UpsFreight::RatesItemOptions.new(
        item_id: 'item_one',
        packaging: commodity_packaging,
        freight_class: '92.5',
        nmfc_code: '16030 sub 1'
      )
    ]
  end

  let(:handling_unit) { :pallet }
  let(:commodity_packaging) { :pallet }

  describe "FreightRateRequest" do
    subject(:freight_rate_request) { full_request["FreightRateRequest"] }

    it do
      is_expected.to include(
        "Request",
        "ShipperNumber",
        "ShipFrom",
        "ShipTo",
        "PaymentInformation",
        "Service",
        "HandlingUnitOne",
        "Commodity"
      )
    end

    describe 'Request' do
      subject(:request_section) { freight_rate_request["Request"] }

      it { is_expected.to have_key("TransactionReference") }

      context 'with a transaction identifier in the options' do
        let(:customer_context) { "MyOrder" }

        it { is_expected.to include("TransactionReference" => { "CustomerContext" => "MyOrder" }) }
      end
    end

    describe 'ShipperNumber' do
      subject(:shipper_number) { freight_rate_request["ShipperNumber"] }
      it { is_expected.to eq('xxx1234') }
    end

    describe 'ShipFrom' do
      subject(:ship_from) { freight_rate_request["ShipFrom"] }

      it do
        is_expected.to include(
          "Name" => 'Developer Test 1',
          "Address" => {
            "AddressLine" => '01 Developer Way',
            "City" => 'Richmond',
            "StateProvinceCode" => 'VA',
            "PostalCode" => '23224',
            "CountryCode" => "US"
          }
        )
      end
    end

    describe 'ShipTo' do
      subject(:ship_to) { freight_rate_request["ShipTo"] }

      it do
        is_expected.to include(
          "Name" => 'Consignee Test 1',
          "Address" => {
            "AddressLine" => '000 Consignee Street',
            "City" => 'Allanton',
            "StateProvinceCode" => 'MO',
            "PostalCode" => '63025',
            "CountryCode" => "US"
          }
        )
      end
    end

    describe 'PaymentInformation' do
      subject(:payment_information) { freight_rate_request["PaymentInformation"] }

      it do
        is_expected.to include(
          "Payer" => hash_including(
            "Name" => "Duck Science",
            "ShipperNumber" => "xxx1234",
            "AttentionName" => "Donald Duck",
            "Address" => hash_including(
              "AddressLine" => ["Duck Street", "Duck Window 2"],
              "City" => "Ducktown",
              "StateProvinceCode" => "NC",
              "PostalCode" => "54321",
              "CountryCode" => "US"
            )
          ),
          "ShipmentBillingOption" => hash_including(
            "Code" => "10" # 10 is prepaid
          )
        )
      end
    end

    describe "Service" do
      subject(:service) { freight_rate_request["Service"] }

      it { is_expected.to eq('Code' => '308') }
    end

    describe 'HandlingUnit information' do
      context 'if package unspecified' do
        it 'has a HandlingUnitOne and assumes a Pallet' do
          expect(freight_rate_request).to have_key("HandlingUnitOne")
        end

        describe "HandlingUnitOne" do
          subject(:handling_unit_one) { freight_rate_request["HandlingUnitOne"] }

          it { is_expected.to include("Quantity" => "1") }
          it { is_expected.to include("Type" => hash_including("Code" => "PLT")) }
        end
      end

      context 'if package is a Skid' do
        let(:handling_unit) { :skid }

        it 'has a HandlingUnitOne with the right options' do
          expect(freight_rate_request).to have_key("HandlingUnitOne")
        end

        describe "HandlingUnitOne" do
          subject(:handling_unit_one) { freight_rate_request["HandlingUnitOne"] }

          it { is_expected.to include("Quantity" => "1") }
          it { is_expected.to include("Type" => hash_including("Code" => "SKD")) }
        end
      end

      context 'if package is a Carboy' do
        let(:handling_unit) { :carboy }

        it 'has a HandlingUnitOne with the right options' do
          expect(freight_rate_request).to have_key("HandlingUnitOne")
        end

        describe "HandlingUnitOne" do
          subject(:handling_unit_one) { freight_rate_request["HandlingUnitOne"] }

          it { is_expected.to include("Quantity" => "1") }
          it { is_expected.to include("Type" => hash_including("Code" => "CBY")) }
        end
      end

      context 'if package is a Totes' do
        let(:handling_unit) { :totes }

        it 'has a HandlingUnitOne with the right options' do
          expect(freight_rate_request).to have_key("HandlingUnitOne")
        end

        describe "HandlingUnitOne" do
          subject(:handling_unit_one) { freight_rate_request["HandlingUnitOne"] }

          it { is_expected.to include("Quantity" => "1") }
          it { is_expected.to include("Type" => hash_including("Code" => "TOT")) }
        end
      end

      context 'if package is loose' do
        let(:handling_unit) { :loose }

        it 'has a HandlingUnitTwo with the right options' do
          expect(freight_rate_request).to have_key("HandlingUnitTwo")
        end

        describe "HandlingUnitTwo" do
          subject(:handling_unit_two) { freight_rate_request["HandlingUnitTwo"] }

          it { is_expected.to include("Quantity" => "1") }
          it { is_expected.to include("Type" => hash_including("Code" => "LOO")) }
        end
      end

      context 'is package is other' do
        let(:handling_unit) { :other }

        it 'has a HandlingUnitTwo with the right options' do
          expect(freight_rate_request).to have_key("HandlingUnitTwo")
        end

        describe "HandlingUnitTwo" do
          subject(:handling_unit_two) { freight_rate_request["HandlingUnitTwo"] }

          it { is_expected.to include("Quantity" => "1") }
          it { is_expected.to include("Type" => hash_including("Code" => "OTH")) }
        end
      end

      context "two packages" do
        let(:packages) { [package_one, package_two] }

        let(:package_one) do
          Physical::Package.new(
            id: 'my_package_1',
            items: [item_one]
          )
        end

        let(:package_two) do
          Physical::Package.new(
            id: 'my_package_2',
            items: [item_two]
          )
        end

        let(:item_one) do
          Physical::Item.new(
            id: 'item_one',
            weight: Measured::Weight(500, :lbs)
          )
        end

        let(:item_two) do
          Physical::Item.new(
            id: 'item_two',
            weight: Measured::Weight(500, :lbs)
          )
        end

        let(:package_options) do
          [
            FriendlyShipping::Services::UpsFreight::RatesPackageOptions.new(
              package_id: package_one.id,
              handling_unit: :pallet,
              item_options: item_one_options
            ),
            FriendlyShipping::Services::UpsFreight::RatesPackageOptions.new(
              package_id: package_two.id,
              handling_unit: :pallet,
              item_options: item_two_options
            )
          ]
        end

        let(:item_one_options) do
          [
            FriendlyShipping::Services::UpsFreight::RatesItemOptions.new(
              item_id: 'item_one',
              packaging: :carton,
              freight_class: '92.5',
              nmfc_code: '16030 sub 1'
            )
          ]
        end

        let(:item_two_options) do
          [
            FriendlyShipping::Services::UpsFreight::RatesItemOptions.new(
              item_id: 'item_two',
              packaging: :pallet,
              freight_class: '92.5',
              nmfc_code: '16030 sub 1'
            )
          ]
        end

        subject(:handling_unit_one) { freight_rate_request["HandlingUnitOne"] }

        it { is_expected.to include("Quantity" => "2") }
        it { is_expected.to include("Type" => hash_including("Code" => "PLT")) }
      end
    end

    describe 'Commodity information' do
      subject(:commodity) { freight_rate_request["Commodity"] }

      it { is_expected.to be_a(Array) }

      context 'payload' do
        subject(:package_payload) { commodity.first }

        let(:package) do
          Physical::Package.new(
            items: [
              Physical::Item.new(
                weight: Measured::Weight(500, :lbs),
                description: 'Can of Socks'
              )
            ]
          )
        end

        it { is_expected.to include("Description" => "Can of Socks") }
        it { is_expected.to include("Weight" => hash_including("UnitOfMeasurement" => { "Code" => "LBS" })) }
        it { is_expected.to include("Weight" => hash_including("Value" => "500.0")) }
        it { is_expected.to include("PackagingType" => hash_including("Code" => "PLT")) }

        context "if the package has another packaging type" do
          let(:commodity_packaging) { :can }

          it { is_expected.to include("PackagingType" => hash_including("Code" => "CAN")) }
        end
      end
    end
  end

  context 'with a Pickup Date given' do
    let(:options) do
      FriendlyShipping::Services::UpsFreight::RatesOptions.new(
        shipping_method: FriendlyShipping::ShippingMethod.new(service_code: '308'),
        shipper_number: 'xxx1234',
        billing_address: billing_location,
        customer_context: customer_context,
        package_options: package_options,
        pickup_request_options: FriendlyShipping::Services::UpsFreight::PickupRequestOptions.new(
          pickup_time_window: Time.new(2019, 11, 10, 17, 0)..Time.new(2019, 11, 10, 17, 0),
          comments: 'Bring pitch forks, there will be hay',
          requester: billing_location,
          requester_email: 'me@example.com'
        )
      )
    end

    it do
      is_expected.to include(
        'FreightRateRequest' => hash_including(
          'PickupRequest' => hash_including(
            'PickupDate' => '20191110',
            'AdditionalComments' => 'Bring pitch forks, there will be hay'
          )
        )
      )
    end
  end
end
