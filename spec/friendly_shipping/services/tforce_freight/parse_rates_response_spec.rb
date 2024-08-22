# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/tforce_freight/parse_rates_response'

RSpec.describe FriendlyShipping::Services::TForceFreight::ParseRatesResponse do
  describe ".call" do
    subject(:call) { described_class.call(request: nil, response: response) }

    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "tforce_freight", "rates", "success.json")) }
    let(:response) { double(body: response_body) }

    it "has the right data" do
      rates = call.data
      expect(rates.length).to eq(3)
      rate = rates.first
      expect(rate).to be_a(FriendlyShipping::Rate)
      expect(rate.total_amount).to eq(Money.new(157_356, "USD"))
      expect(rate.shipping_method.name).to eq("TForce Freight LTL")
      expect(rate.data).to eq(
        customer_context: "140fdff5-3df5-419e-bc3f-84b781f55cc9",
        commodities: [],
        days_in_transit: 3,
        cost_breakdown: [
          { "code" => "DSCNT", "description" => "Discount", "unit" => "USD", "value" => "1987.05" },
          { "code" => "DSCNT_RATE", "description" => "DiscountRate", "unit" => "%", "value" => "75.00" },
          { "code" => "INDE", "description" => "INSIDE_DL", "unit" => "USD", "value" => "169.00" },
          { "code" => "INPU", "description" => "INSIDE_PU", "unit" => "USD", "value" => "169.00" },
          { "code" => "LIFD", "description" => "LIFT_GATE_DL", "unit" => "USD", "value" => "175.00" },
          { "code" => "LIFO", "description" => "LIFT_GATE_PU", "unit" => "USD", "value" => "175.00" },
          { "code" => "FUEL_SUR", "description" => "FuelSurcharge Fee", "unit" => "USD", "value" => "223.21" },
          { "code" => "LND_GROSS", "description" => "LND_GROSS", "unit" => "USD", "value" => "2649.40" },
          { "code" => "AFTR_DSCNT", "description" => "AFTR_DSCNT", "unit" => "USD", "value" => "662.35" }
        ]
      )
    end
  end
end
