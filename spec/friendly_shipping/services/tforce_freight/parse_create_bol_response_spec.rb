# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::ParseCreateBOLResponse do
  describe ".call" do
    subject(:call) { described_class.call(request: nil, response: response) }

    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "tforce_freight", "create_bol", "success.json")) }
    let(:response) { double(body: response_body) }

    it "has the right data" do
      result = call.data
      expect(result).to be_a(FriendlyShipping::Services::TForceFreight::ShipmentInformation)
      expect(result.bol_id).to eq(46_176_429)
      expect(result.pro_number).to eq("020968290")
      expect(result.origin_service_center).to eq("LOS")
      expect(result.email_sent).to eq(false)
      expect(result.origin_is_rural).to eq(true)
      expect(result.destination_is_rural).to eq(false)

      expect(result.rates).to eq(
        aftr_dscnt: 603.25,
        dscnt: 1809.75,
        dscnt_rate: 75.0,
        exli: 74.5,
        fuel_sur: 255.78,
        hicst: 22.0,
        inde: 169.0,
        lifo: 175.0,
        lnd_gross: 2413.0,
        pfff: 45.0,
        resp: 207.0
      )

      expect(result.total_charges).to eq(Money.new(155_153, "USD"))
      expect(result.billable_weight).to eq(Measured::Weight(1000, :lb))
      expect(result.days_in_transit).to eq(1)
      expect(result.shipping_method).to eq(FriendlyShipping::Services::TForceFreight::SHIPPING_METHODS.first)

      expect(result.documents).to be_a(Array)
      expect(result.documents.size).to eq(2)

      document_1 = result.documents[0]
      expect(document_1.document_type).to eq(:tforce_bol)
      expect(document_1.document_format).to eq(:pdf)
      expect(document_1.status).to eq("NFO")
      expect(document_1.binary).to start_with("%PDF-")

      document_2 = result.documents[1]
      expect(document_2.document_type).to eq(:label)
      expect(document_2.document_format).to eq(:pdf)
      expect(document_2.status).to eq("NFO")
      expect(document_2.binary).to start_with("%PDF-")

      expect(result.data).to eq(
        cost_breakdown: {
          "Rates" => {
            "AFTR_DSCNT" => "603.25",
            "DSCNT" => "1809.75",
            "DSCNT_RATE" => "75.00",
            "EXLI" => "74.50",
            "FUEL_SUR" => "255.78",
            "HICST" => "22.00",
            "INDE" => "169.00",
            "LIFO" => "175.00",
            "LND_GROSS" => "2413.00",
            "PFFF" => "45.00",
            "RESP" => "207.00"
          },
          "TotalShipmentCharge" => "1551.53",
          "BillableShipmentWeight" => "1000"
        }
      )
    end
  end
end
