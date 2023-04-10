# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups/serialize_shipment_confirm_request'

RSpec.describe FriendlyShipping::Services::Ups::SerializeShipmentConfirmRequest do
  let(:origin) do
    FactoryBot.build(
      :physical_location,
      name: 'John Doe',
      company_name: 'Company',
      address1: 'Some St',
      address2: 'Northwest',
      region: 'NC',
      city: 'Raleigh',
      zip: '27615'
    )
  end

  let(:destination) do
    FactoryBot.build(
      :physical_location,
      address1: '7007 Sea World Dr',
      city: 'Orlando',
      region: 'FL',
      zip: '32821'
    )
  end

  let(:package) do
    Physical::Package.new(
      id: 'package_1',
      items: [
        Physical::Item.new(
          weight: Measured::Weight.new(5, :pounds),
          description: 'Wooden block',
          cost: Money.new(495, 'USD')
        )
      ],
      container: Physical::Box.new(
        dimensions: [
          Measured::Length.new(10, :centimeters),
          Measured::Length.new(10, :centimeters),
          Measured::Length.new(10, :centimeters),
        ]
      )
    )
  end

  let(:shipment) do
    FactoryBot.build(
      :physical_shipment,
      origin: origin,
      destination: destination,
      packages: [package]
    )
  end

  let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: '03') }

  let(:options) do
    FriendlyShipping::Services::Ups::LabelOptions.new(
      shipping_method: shipping_method,
      shipper_number: '12345'
    )
  end

  subject do
    Nokogiri::XML(
      described_class.call(shipment: shipment, options: options)
    )
  end

  it 'contains the right data' do
    aggregate_failures do
      expect(subject.at_xpath('//ShipmentConfirmRequest')).to be_present
      expect(subject.at_xpath('//ShipmentConfirmRequest/Request')).to be_present
      expect(subject.at_xpath('//ShipmentConfirmRequest/Request/RequestAction').text).to eq('ShipConfirm')
      expect(subject.at_xpath('//ShipmentConfirmRequest/Request/RequestOption').text).to eq('validate')
      expect(subject.at_xpath('//ShipmentConfirmRequest/Request/SubVersion').text).to eq('1707')
      expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/Service/Code').text).to eq('03')
      expect(
        subject.at_xpath('//ShipmentConfirmRequest/Shipment/Shipper/Address/AddressLine1').text
      ).to eq('Some St')
      # This is passed in as part of our credentials
      expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/Shipper/ShipperNumber').text).to be_present
      expect(
        subject.at_xpath('//ShipmentConfirmRequest/Shipment/ShipTo/ShipperAssignedIdentificationNumber')
      ).not_to be_present
      expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/ShipFrom')).not_to be_present
      expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/Package')).to be_present
      expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/Package/PackagingType/Code').text).to eq('02')
      expect(
        subject.at_xpath('//ShipmentConfirmRequest/Shipment/Package/PackageWeight/UnitOfMeasurement/Code').text
      ).to eq('LBS')
      expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/Package/PackageWeight/Weight').text).to eq('5')
    end
  end

  context 'with a different shipper' do
    let(:shipper) do
      FactoryBot.build(
        :physical_location,
        name: 'Jack Doe',
        company_name: 'Company',
        address1: 'Some St',
        address2: 'East',
        region: 'NV',
        city: 'Reno',
        zip: '89431'
      )
    end

    let(:options) do
      FriendlyShipping::Services::Ups::LabelOptions.new(
        shipping_method: shipping_method,
        shipper_number: '12345',
        shipper: shipper
      )
    end

    it 'contains an extra ShipFrom element' do
      aggregate_failures do
        expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/ShipFrom')).to be_present
        expect(
          subject.at_xpath('//ShipmentConfirmRequest/Shipment/ShipFrom/Address/AddressLine1').text
        ).to eq('Some St')
      end
    end
  end

  context 'with a private address (without company)' do
    let(:destination) do
      FactoryBot.build(
        :physical_location,
        company_name: nil,
        address1: '7007 Sea World Dr',
        city: 'Orlando',
        region: 'FL',
        zip: '32821'
      )
    end

    it "contains the name of the recipient instead of the company" do
      expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/ShipTo/CompanyName').text).to eq("Jane Doe")
      expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/ShipTo/AttentionName')).not_to be_present
    end
  end

  context 'carbon neutral shipping' do
    let(:options) do
      FriendlyShipping::Services::Ups::LabelOptions.new(
        shipping_method: shipping_method,
        shipper_number: '12345',
        carbon_neutral: true
      )
    end

    it "contains the carbon neutral indicator in the right spot" do
      expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/ShipmentServiceOptions/UPScarbonneutralIndicator')).to be_present
    end
  end

  context 'with third-party billing' do
    let(:options) do
      FriendlyShipping::Services::Ups::LabelOptions.new(
        shipping_method: shipping_method,
        shipper_number: 'X234X',
        billing_options: billing_options
      )
    end

    let(:billing_options) do
      FriendlyShipping::Services::Ups::LabelBillingOptions.new(
        bill_third_party: true,
        billing_account: '12345',
        billing_zip: '22222',
        billing_country: 'US'
      )
    end

    it 'contains the relevant xml elements' do
      expect(subject.at('Shipper/ShipperNumber').text).to eq('X234X')
      expect(subject.at('BillThirdPartyShipper/AccountNumber').text).to eq('12345')
      expect(subject.at('BillThirdPartyShipper/ThirdParty/Address/PostalCode').text).to eq('22222')
      expect(subject.at('BillThirdPartyShipper/ThirdParty/Address/CountryCode').text).to eq('US')
    end
  end

  context 'with a package that has shipper release set' do
    let(:options) do
      FriendlyShipping::Services::Ups::LabelOptions.new(
        shipping_method: shipping_method,
        shipper_number: '12345',
        package_options: [package_options]
      )
    end

    let(:package_options) do
      FriendlyShipping::Services::Ups::LabelPackageOptions.new(
        package_id: 'package_1',
        shipper_release: true
      )
    end

    it 'contains the relevant XML element' do
      expect(subject.at('//ShipmentConfirmRequest/Shipment/Package/PackageServiceOptions/ShipperReleaseIndicator')).to be_present
    end
  end

  context 'with international destination and third party duties and fees billing' do
    let(:destination) do
      FactoryBot.build(
        :physical_location,
        address1: '1000 Airport Rd',
        city: 'Edmonton',
        region: 'AB',
        zip: 'T9E 0V3',
        country: 'CA'
      )
    end

    let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: '12', international: true) }

    let(:options) do
      FriendlyShipping::Services::Ups::LabelOptions.new(
        shipping_method: shipping_method,
        shipper_number: 'X234X',
        billing_options: billing_options,
        terms_of_shipment: :delivery_duty_paid,
      )
    end

    let(:billing_options) do
      FriendlyShipping::Services::Ups::LabelBillingOptions.new(
        billing_account: '12345',
        billing_zip: '22222',
        billing_country: 'US'
      )
    end

    it 'contains the relevant xml elements' do
      expect(subject.at('Shipper/ShipperNumber').text).to eq('X234X')
      expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/ItemizedPaymentInformation/ShipmentCharge/BillShipper/AccountNumber').text).to eq('X234X')
      expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/ItemizedPaymentInformation/ShipmentCharge/BillThirdParty/BillThirdPartyConsignee/AccountNumber').text).to eq('12345')
      expect(subject.at('Shipment/Description').text).to eq('Wooden block')
      expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/ShipTo/CompanyName').text).to eq("Company")
      expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/ShipTo/AttentionName').text).to eq("Jane Doe")
    end

    context 'with a private address (without company)' do
      let(:destination) do
        FactoryBot.build(
          :physical_location,
          company_name: nil,
          address1: '1000 Airport Rd',
          city: 'Edmonton',
          region: 'AB',
          zip: 'T9E 0V3',
          country: 'CA'
        )
      end

      it 'contains the relevant xml elements' do
        expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/ShipTo/CompanyName').text).to eq("Jane Doe")
        expect(subject.at_xpath('//ShipmentConfirmRequest/Shipment/ShipTo/AttentionName').text).to eq("Jane Doe")
      end
    end
  end

  context 'with international destination and paperless invoicing enabled' do
    let(:destination) do
      FactoryBot.build(
        :physical_location,
        address1: '1000 Airport Rd',
        city: 'Edmonton',
        region: 'AB',
        zip: 'T9E 0V3',
        country: 'CA'
      )
    end

    let(:shipping_method) do
      FriendlyShipping::ShippingMethod.new(
        service_code: '12',
        international: true
      )
    end

    let(:options) do
      FriendlyShipping::Services::Ups::LabelOptions.new(
        shipping_method: shipping_method,
        shipper_number: '12345',
        paperless_invoice: true,
        terms_of_shipment: :cost_and_freight,
        package_options: package_options
      )
    end

    let(:package_options) do
      [
        FriendlyShipping::Services::Ups::LabelPackageOptions.new(
          package_id: package.id,
          item_options: item_options
        )
      ]
    end

    let(:item_options) do
      [
        FriendlyShipping::Services::Ups::LabelItemOptions.new(
          item_id: package.items.first.id,
          commodity_code: "6116.10.0000",
          country_of_origin: "CA"
        )
      ]
    end

    it 'contains the right data' do
      expect(subject.at('ShipmentServiceOptions/InternationalForms/FormType').text).to eq('01')
      expect(subject.at('ShipmentServiceOptions/InternationalForms/InvoiceDate').text).to eq(Date.current.strftime('%Y%m%d'))
      expect(subject.at('ShipmentServiceOptions/InternationalForms/ReasonForExport').text).to eq('SALE')
      expect(subject.at('ShipmentServiceOptions/InternationalForms/CurrencyCode').text).to eq('USD')
      expect(subject.at('ShipmentServiceOptions/InternationalForms/TermsOfShipment').text).to eq('CFR')
      expect(subject.at('ShipmentServiceOptions/InternationalForms/Product/Description').text).to eq('Wooden block')
      expect(subject.at('ShipmentServiceOptions/InternationalForms/Product/CommodityCode').text).to eq('6116.10.0000')
      expect(subject.at('ShipmentServiceOptions/InternationalForms/Product/OriginCountryCode').text).to eq('CA')
      expect(subject.at('ShipmentServiceOptions/InternationalForms/Product/Unit/Value').text).to eq('4.95')
      expect(subject.at('ShipmentServiceOptions/InternationalForms/Product/Unit/Number').text).to eq('1')
      expect(subject.at('ShipmentServiceOptions/InternationalForms/Product/Unit/UnitOfMeasurement/Code').text).to eq('NMB')
    end

    context 'with a product containing a long description' do
      let(:package) do
        Physical::Package.new(
          id: 'package_1',
          items: [
            Physical::Item.new(
              weight: Measured::Weight.new(5, :pounds),
              description: 'Wooden block with a terribly long description',
              cost: Money.new(495, 'USD')
            )
          ],
          container: Physical::Box.new(
            dimensions: [
              Measured::Length.new(10, :centimeters),
              Measured::Length.new(10, :centimeters),
              Measured::Length.new(10, :centimeters),
            ]
          )
        )
      end

      it 'limits the product description length to the UPS limit of 35 characters' do
        expect(subject.at('InternationalForms/Product/Description').text).to eq('Wooden block with a terribly long d')
      end
    end
  end
end
