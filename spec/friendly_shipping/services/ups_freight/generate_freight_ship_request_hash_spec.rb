# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/generate_freight_ship_request_hash'
require 'friendly_shipping/services/ups_freight/label_options'

RSpec.describe FriendlyShipping::Services::UpsFreight::GenerateFreightShipRequestHash do
  subject(:full_request) { JSON.parse(described_class.call(shipment: shipment, options: options).to_json) }

  let(:shipment) { Physical::Shipment.new(structures: structures, origin: origin, destination: destination) }

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

  let(:structures) { [pallet_1] }

  let(:pallet_1) do
    Physical::Structure.new(
      id: 'pallet 1',
      packages: [package_1]
    )
  end

  let(:package_1) do
    Physical::Package.new(
      id: 'package 1',
      description: 'Can of Socks',
      items: [
        Physical::Item.new(
          weight: Measured::Weight(500, :lbs)
        )
      ]
    )
  end

  let(:options) do
    FriendlyShipping::Services::UpsFreight::LabelOptions.new(
      shipping_method: FriendlyShipping::ShippingMethod.new(service_code: '308'),
      shipper_number: 'xxx1234',
      billing_address: billing_location,
      customer_context: customer_context,
      structure_options: structure_options
    )
  end

  let(:customer_context) { 'order-12345' }

  let(:billing_location) do
    Physical::Location.new(
      name: "Donald Duck",
      company_name: "Duck Science",
      address1: "Duck Street, Duck Window 2",
      city: "Ducktown",
      zip: "54321",
      region: "NC",
      country: "US"
    )
  end

  let(:structure_options) do
    [
      FriendlyShipping::Services::UpsFreight::LabelStructureOptions.new(
        structure_id: pallet_1.id,
        handling_unit: handling_unit,
        package_options: package_1_options
      )
    ]
  end

  let(:package_1_options) do
    [
      FriendlyShipping::Services::UpsFreight::LabelPackageOptions.new(
        package_id: 'package 1',
        packaging: commodity_packaging,
        freight_class: '92.5',
        nmfc_code: '16030 sub 1'
      )
    ]
  end

  let(:handling_unit) { :pallet }
  let(:commodity_packaging) { :pallet }

  describe "FreightShipRequest" do
    subject(:freight_ship_request) { full_request["FreightShipRequest"]["Shipment"] }

    it do
      is_expected.to include(
        "ShipperNumber",
        "ShipFrom",
        "ShipTo",
        "PaymentInformation",
        "Service",
        "HandlingUnitOne",
        "Commodity"
      )
    end

    describe 'ShipperNumber' do
      subject(:shipper_number) { freight_ship_request["ShipperNumber"] }
      it { is_expected.to eq('xxx1234') }
    end

    describe 'ShipFrom' do
      subject(:ship_from) { freight_ship_request["ShipFrom"] }

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
      subject(:ship_to) { freight_ship_request["ShipTo"] }

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
      subject(:payment_information) { freight_ship_request["PaymentInformation"] }

      it do
        is_expected.to include(
          "Payer" => hash_including(
            "Name" => "Duck Science",
            "ShipperNumber" => "xxx1234",
            "AttentionName" => "Donald Duck",
            "Address" => hash_including(
              "AddressLine" => "Duck Street, Duck Window 2",
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
      subject(:service) { freight_ship_request["Service"] }

      it { is_expected.to eq('Code' => '308') }
    end

    describe 'HandlingUnit information' do
      context 'if package unspecified' do
        it 'has a HandlingUnitOne and assumes a Pallet' do
          expect(freight_ship_request).to have_key("HandlingUnitOne")
        end

        describe "HandlingUnitOne" do
          subject(:handling_unit_one) { freight_ship_request["HandlingUnitOne"] }

          it { is_expected.to include("Quantity" => "1") }
          it { is_expected.to include("Type" => hash_including("Code" => "PLT")) }
        end
      end

      context 'if package is a Skid' do
        let(:handling_unit) { :skid }

        it 'has a HandlingUnitOne with the right options' do
          expect(freight_ship_request).to have_key("HandlingUnitOne")
        end

        describe "HandlingUnitOne" do
          subject(:handling_unit_one) { freight_ship_request["HandlingUnitOne"] }

          it { is_expected.to include("Quantity" => "1") }
          it { is_expected.to include("Type" => hash_including("Code" => "SKD")) }
        end
      end

      context 'if package is a Carboy' do
        let(:handling_unit) { :carboy }

        it 'has a HandlingUnitOne with the right options' do
          expect(freight_ship_request).to have_key("HandlingUnitOne")
        end

        describe "HandlingUnitOne" do
          subject(:handling_unit_one) { freight_ship_request["HandlingUnitOne"] }

          it { is_expected.to include("Quantity" => "1") }
          it { is_expected.to include("Type" => hash_including("Code" => "CBY")) }
        end
      end

      context 'if package is a Totes' do
        let(:handling_unit) { :totes }

        it 'has a HandlingUnitOne with the right options' do
          expect(freight_ship_request).to have_key("HandlingUnitOne")
        end

        describe "HandlingUnitOne" do
          subject(:handling_unit_one) { freight_ship_request["HandlingUnitOne"] }

          it { is_expected.to include("Quantity" => "1") }
          it { is_expected.to include("Type" => hash_including("Code" => "TOT")) }
        end
      end

      context 'if package is loose' do
        let(:handling_unit) { :loose }

        it 'has a HandlingUnitTwo with the right options' do
          expect(freight_ship_request).to have_key("HandlingUnitTwo")
        end

        describe "HandlingUnitTwo" do
          subject(:handling_unit_two) { freight_ship_request["HandlingUnitTwo"] }

          it { is_expected.to include("Quantity" => "1") }
          it { is_expected.to include("Type" => hash_including("Code" => "LOO")) }
        end
      end

      context 'is package is other' do
        let(:handling_unit) { :other }

        it 'has a HandlingUnitTwo with the right options' do
          expect(freight_ship_request).to have_key("HandlingUnitTwo")
        end

        describe "HandlingUnitTwo" do
          subject(:handling_unit_two) { freight_ship_request["HandlingUnitTwo"] }

          it { is_expected.to include("Quantity" => "1") }
          it { is_expected.to include("Type" => hash_including("Code" => "OTH")) }
        end
      end

      context "two packages" do
        let(:structures) { [pallet_1, pallet_2] }

        let(:pallet_1) do
          Physical::Structure.new(
            id: 'pallet 1',
            packages: [package_1]
          )
        end

        let(:pallet_2) do
          Physical::Structure.new(
            id: 'pallet 2',
            packages: [package_2]
          )
        end

        let(:package_1) do
          Physical::Package.new(
            id: 'package 1',
            items: [
              Physical::Item.new(
                weight: Measured::Weight(500, :lbs)
              )
            ]
          )
        end

        let(:package_2) do
          Physical::Package.new(
            id: 'package 2',
            items: [
              Physical::Item.new(
                weight: Measured::Weight(500, :lbs)
              )
            ]
          )
        end

        let(:structure_options) do
          [
            FriendlyShipping::Services::UpsFreight::LabelStructureOptions.new(
              structure_id: pallet_1.id,
              handling_unit: :pallet,
              package_options: package_1_options
            ),
            FriendlyShipping::Services::UpsFreight::LabelStructureOptions.new(
              structure_id: pallet_2.id,
              handling_unit: :pallet,
              package_options: package_2_options
            )
          ]
        end

        let(:package_1_options) do
          [
            FriendlyShipping::Services::UpsFreight::LabelPackageOptions.new(
              package_id: 'package 1',
              packaging: :carton,
              freight_class: '92.5',
              nmfc_code: '16030 sub 1'
            )
          ]
        end

        let(:package_2_options) do
          [
            FriendlyShipping::Services::UpsFreight::LabelPackageOptions.new(
              package_id: 'package 2',
              packaging: :pallet,
              freight_class: '92.5',
              nmfc_code: '16030 sub 1'
            )
          ]
        end

        subject(:handling_unit_one) { freight_ship_request["HandlingUnitOne"] }

        it { is_expected.to include("Quantity" => "2") }
        it { is_expected.to include("Type" => hash_including("Code" => "PLT")) }
      end
    end

    describe 'Commodity information' do
      subject(:commodity) { freight_ship_request["Commodity"] }

      it { is_expected.to be_a(Array) }

      context 'payload' do
        subject(:package_payload) { commodity.first }

        let(:pallet) do
          Physical::Structure.new(
            packages: [
              Physical::Package.new(
                description: 'Can of Socks',
                items: [
                  Physical::Item.new(
                    weight: Measured::Weight(500, :lbs)
                  )
                ]
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

    describe "Reference information" do
      let(:options) do
        FriendlyShipping::Services::UpsFreight::LabelOptions.new(
          shipping_method: FriendlyShipping::ShippingMethod.new(service_code: '308'),
          shipper_number: 'xxx1234',
          billing_address: billing_location,
          reference_numbers: [
            { code: :purchase_order_number, value: "H123456" },
            { code: :consignee_reference, value: "55473" }
          ],
          structure_options: structure_options
        )
      end

      subject(:references) { freight_ship_request["Reference"] }

      it { is_expected.to be_a(Array) }

      context "first reference" do
        subject(:first_reference) { references.first }
        it { is_expected.to eq("Number" => { "Code" => "28", "Value" => "H123456" }) }
      end

      context "second reference" do
        subject(:second_reference) { references.last }
        it { is_expected.to eq("Number" => { "Code" => "CO", "Value" => "55473" }) }
      end
    end
  end
end
