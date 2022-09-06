# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/parse_freight_label_response'

RSpec.describe FriendlyShipping::Services::UpsFreight::ParseFreightLabelResponse do
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ups_freight', 'labels', 'success.json')).read }
  let(:response) { double(body: response_body) }
  let(:request) { FriendlyShipping::Request.new(url: 'http://www.example.com') }

  subject { described_class.call(request: request, response: response) }

  it 'has the right shipment information' do
    shipment_information = subject.data
    expect(shipment_information).to be_a(FriendlyShipping::Services::UpsFreight::ShipmentInformation)

    expect(shipment_information.documents.size).to eq(2)
    expect(shipment_information.documents).to all(be_a(FriendlyShipping::Services::UpsFreight::ShipmentDocument))

    expect(shipment_information.documents.first.format).to eq(:pdf)
    expect(shipment_information.documents.first.document_type).to eq(:label)
    expect(shipment_information.documents.first.binary).to be_present

    expect(shipment_information.documents.last.format).to eq(:pdf)
    expect(shipment_information.documents.last.document_type).to eq(:ups_bol)
    expect(shipment_information.documents.last.binary).to be_present

    expect(shipment_information.number).to eq("022438065")
    expect(shipment_information.pickup_request_number).to eq("348742132")
    expect(shipment_information.total).to eq(Money.new(17_989, "USD"))
    expect(shipment_information.bol_id).to eq("45760188")

    expect(shipment_information.shipping_method).to be_a(FriendlyShipping::ShippingMethod)
    expect(shipment_information.shipping_method.name).to eq("UPS Freight LTL")
    expect(shipment_information.shipping_method.service_code).to eq("308")

    expect(shipment_information.warnings).to eq("3289315415: Bogus warning for test purposes")
    expect(shipment_information.data).to eq(
      {
        cost_breakdown: {
          "BillableShipmentWeight" => "500",
          "TotalShipmentCharge" => "179.89",
          "Rates" => {
            "2" => "16.35",
            "DSCNT" => "490.61",
            "DSCNT_RATE" => "75.00",
            "LND_GROSS" => "654.15",
            "AFTR_DSCNT" => "163.54"
          }
        }
      }
    )
  end

  context 'when rates are missing from response' do
    let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ups_freight', 'labels', 'success_without_rates.json')).read }

    it 'has the right shipment information' do
      shipment_information = subject.data
      expect(shipment_information).to be_a(FriendlyShipping::Services::UpsFreight::ShipmentInformation)

      expect(shipment_information.documents.size).to eq(2)
      expect(shipment_information.documents).to all(be_a(FriendlyShipping::Services::UpsFreight::ShipmentDocument))

      expect(shipment_information.documents.first.format).to eq(:pdf)
      expect(shipment_information.documents.first.document_type).to eq(:label)
      expect(shipment_information.documents.first.binary).to be_present

      expect(shipment_information.documents.last.format).to eq(:pdf)
      expect(shipment_information.documents.last.document_type).to eq(:ups_bol)
      expect(shipment_information.documents.last.binary).to be_present

      expect(shipment_information.number).to eq("022438065")
      expect(shipment_information.pickup_request_number).to eq("348742132")
      expect(shipment_information.total).to be_nil
      expect(shipment_information.bol_id).to eq("45760188")

      expect(shipment_information.shipping_method).to be_a(FriendlyShipping::ShippingMethod)
      expect(shipment_information.shipping_method.name).to eq("UPS Freight LTL")
      expect(shipment_information.shipping_method.service_code).to eq("308")

      expect(shipment_information.warnings).to eq("9369056: No rates available.")
      expect(shipment_information.data).to eq(
        {
          cost_breakdown: {
            "BillableShipmentWeight" => "500",
            "Rates" => {}
          }
        }
      )
    end
  end
end
