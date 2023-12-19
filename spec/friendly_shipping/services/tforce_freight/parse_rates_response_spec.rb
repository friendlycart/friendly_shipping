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
    end
  end
end
