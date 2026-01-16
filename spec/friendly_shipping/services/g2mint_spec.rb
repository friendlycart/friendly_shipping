# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::G2Mint do
  subject(:service) { described_class.new(api_key: api_key, test: false) }

  let(:api_key) { ENV.fetch("G2MINT_API_KEY", "test_api_key") }

  describe "#carriers" do
    subject(:carriers) { service.carriers.value! }

    it "has only one carrier with one shipping method" do
      expect(carriers.length).to eq(1)
      expect(carriers.first.id).to eq("g2mint")
      expect(carriers.first.name).to eq("G2Mint")
      expect(carriers.first.shipping_methods.map(&:service_code)).to contain_exactly("ltl")
      expect(carriers.first.shipping_methods.map(&:name)).to contain_exactly("LTL Freight")
    end
  end

  describe "#api_base" do
    context "when test mode is false" do
      subject(:service) { described_class.new(api_key: api_key, test: false) }

      it "returns the production API URL" do
        expect(service.send(:api_base)).to eq("https://api.g2mint.com")
      end
    end

    context "when test mode is true" do
      it "returns the test API URL" do
        expect(service.send(:api_base)).to eq("https://sdg-api.g2mint.com")
      end
    end
  end

  describe "initialization" do
    it "sets the api_key" do
      expect(service.api_key).to eq(api_key)
    end

    it "sets the test flag" do
      expect(service.test).to eq(false)
    end

    it "creates an HTTP client" do
      expect(service.client).to be_a(FriendlyShipping::HttpClient)
    end
  end
end
