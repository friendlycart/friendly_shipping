# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::G2Mint::REST::ParseRatesResponse do
  describe ".call" do
    subject(:call) { described_class.call(request: nil, response: response) }

    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "g2mint", "rates", "success.json")) }
    let(:response) { double(body: response_body) }

    it "returns an ApiResult" do
      expect(call).to be_a(FriendlyShipping::ApiResult)
    end

    it "has the right number of rates" do
      rates = call.data
      expect(rates.length).to eq(3)
    end

    describe "first rate (R+L Standard)" do
      subject(:rate) { call.data.first }

      it "is a Rate object" do
        expect(rate).to be_a(FriendlyShipping::Rate)
      end

      it "has the correct total amount" do
        expect(rate.total_amount).to eq(Money.new(68_104, "USD"))
      end

      it "has the correct shipping method" do
        expect(rate.shipping_method.name).to eq("Standard")
        expect(rate.shipping_method.service_code).to eq("standard")
      end

      it "has the correct data" do
        expect(rate.data[:request_id]).to eq("17cfde26-276d-4153-a393-f4352f88c32a")
        expect(rate.data[:carrier_code]).to eq("RNLO")
        expect(rate.data[:carrier_name]).to eq("R+L Carriers")
        expect(rate.data[:service_level]).to eq("Standard")
        expect(rate.data[:quote_number]).to eq("6185341")
        expect(rate.data[:delivery_date]).to eq("2026-01-20")
        expect(rate.data[:estimated_transit_time]).to eq(2)
      end

      it "has pricing breakdown" do
        expect(rate.data[:pricing][:subtotal]).to eq(25)
        expect(rate.data[:pricing][:discount_percentage]).to eq(91.4)
        expect(rate.data[:pricing][:line_haul]).to eq(524.68)
        expect(rate.data[:pricing][:fuel_surcharge]).to eq(156.36)
      end
    end

    describe "second rate (R+L Guaranteed)" do
      subject(:rate) { call.data.second }

      it "has the correct total amount" do
        expect(rate.total_amount).to eq(Money.new(78_212, "USD"))
      end

      it "has the correct shipping method" do
        expect(rate.shipping_method.name).to eq("Guaranteed")
      end

      it "has accessorials" do
        expect(rate.data[:accessorials]).to include(
          { "code" => "GUARANTEE", "name" => "Guaranteed Service", "cost" => 104.42 }
        )
      end
    end

    describe "third rate (TForce)" do
      subject(:rate) { call.data.third }

      it "has the correct total amount" do
        expect(rate.total_amount).to eq(Money.new(58_452, "USD"))
      end

      it "has the correct carrier" do
        expect(rate.data[:carrier_code]).to eq("TFXF")
        expect(rate.data[:carrier_name]).to eq("TForce Freight")
      end

      it "has the correct shipping method" do
        expect(rate.shipping_method.name).to eq("TForce Freight LTL")
      end
    end
  end
end
