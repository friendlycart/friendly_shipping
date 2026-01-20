# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::G2Mint do
  # Set test: false when recording VCR cassettes. G2Mint does not yet provide a test API.
  subject(:service) { described_class.new(api_key: api_key, test: true) }

  let(:api_key) { ENV.fetch("G2MINT_API_KEY", "test_api_key") }
  let(:account_id) { ENV.fetch("G2MINT_ACCOUNT_ID", "test_account_id") }
  let(:owner_tenant_id) { ENV.fetch("G2MINT_OWNER_TENANT_ID", "test_owner_tenant_id") }

  let(:origin) do
    FactoryBot.build(
      :physical_location,
      company_name: "Origin Co",
      address1: "123 Maple St",
      address2: "Suite 100",
      city: "New York",
      region: "NY",
      zip: "10001",
      country: "US"
    )
  end

  let(:destination) do
    FactoryBot.build(
      :physical_location,
      company_name: "Destination Co",
      address1: "456 Oak St",
      address2: "Suite 200",
      city: "Boulder",
      region: "CO",
      zip: "80301",
      country: "US"
    )
  end

  let(:bill_to_location) do
    FactoryBot.build(
      :physical_location,
      company_name: "Bill To Co",
      address1: "789 Pine St",
      city: "Chicago",
      region: "IL",
      zip: "60601",
      country: "US"
    )
  end

  let(:package) do
    Physical::Package.new(
      id: "pkg-1",
      weight: Measured::Weight(500, :lb),
      dimensions: [
        Measured::Length(24, :in),
        Measured::Length(18, :in),
        Measured::Length(12, :in)
      ]
    )
  end

  let(:structure) do
    Physical::Structure.new(
      id: "structure-1",
      packages: [package],
      dimensions: [
        Measured::Length(48, :in),
        Measured::Length(48, :in),
        Measured::Length(48, :in)
      ]
    )
  end

  let(:shipment) do
    Physical::Shipment.new(
      origin: origin,
      destination: destination,
      structures: [structure]
    )
  end

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
      expect(service.test).to be(true)
    end

    it "creates an HTTP client" do
      expect(service.client).to be_a(FriendlyShipping::HttpClient)
    end
  end

  describe "#rates" do
    subject(:rates) { service.rates(shipment, options: options) }

    let(:options) do
      FriendlyShipping::Services::G2Mint::REST::RatesOptions.new(
        request_id: "test-request-123",
        account_id: account_id,
        owner_tenant: owner_tenant_id,
        bill_to_location: bill_to_location,
        bill_to_location_name: "Test Billing",
        bill_to_contact: {
          firstName: "John",
          lastName: "Doe",
          phoneNumber: "555-1234",
          email: "john@example.com"
        },
        direction: "OUTBOUND",
        pickup_date: Date.parse("2026-01-15"),
        structure_options: [
          FriendlyShipping::Services::G2Mint::REST::StructureOptions.new(
            structure_id: "structure-1",
            package_options: [
              FriendlyShipping::Services::G2Mint::REST::PackageOptions.new(
                package_id: "pkg-1",
                freight_class: "250"
              )
            ]
          )
        ]
      )
    end

    context "with a successful request", vcr: { cassette_name: "g2mint/rates/success" } do
      it { is_expected.to be_a Dry::Monads::Success }

      it "has all the right data" do
        result = rates.value!.data
        expect(result).to be_an(Array)
        expect(result.length).to eq(4)
      end

      it "returns rates from multiple carriers" do
        result = rates.value!.data
        carrier_codes = result.map { |r| r.data[:carrier_code] }.uniq
        expect(carrier_codes).to contain_exactly("RNLO", "TFXF")
      end

      it "has correct rate details for R+L Standard rate" do
        rate = rates.value!.data.first
        expect(rate).to be_a(FriendlyShipping::Rate)
        expect(rate.total_amount).to eq(Money.new(178_874, "USD"))
        expect(rate.data[:carrier_name]).to eq("R+L Carriers")
        expect(rate.data[:service_level]).to eq("Standard")
        expect(rate.data[:quote_number]).to eq("7133416")
        expect(rate.data[:estimated_transit_time]).to eq(6)
        expect(rate.data[:accessorials]).to eq([{
          "code" => "ARMCF",
          "cost" => 149.08,
          "name" => "MANHATTAN CONGESTION FEE"
        }])
      end

      it "has correct rate details for R+L Guaranteed rate" do
        rate = rates.value!.data.second
        expect(rate.total_amount).to eq(Money.new(203_785, "USD"))
        expect(rate.data[:carrier_name]).to eq("R+L Carriers")
        expect(rate.data[:service_level]).to eq("Guaranteed")
        expect(rate.data[:quote_number]).to eq("25672911")
        expect(rate.data[:estimated_transit_time]).to eq(6)
        expect(rate.data[:accessorials]).to include(
          { "code" => "ARMCF", "cost" => 148.83, "name" => "MANHATTAN CONGESTION FEE" },
          { "code" => "GUARANTEE", "cost" => 252.2, "name" => "Guaranteed Service" }
        )
      end

      it "has correct rate details for R+L Guaranteed AM rate" do
        rate = rates.value!.data.third
        expect(rate.total_amount).to eq(Money.new(216_240, "USD"))
        expect(rate.data[:carrier_code]).to eq("RNLO")
        expect(rate.data[:carrier_name]).to eq("R+L Carriers")
        expect(rate.data[:service_level]).to eq("Guaranteed AM")
        expect(rate.data[:quote_number]).to eq("33896818")
        expect(rate.data[:estimated_transit_time]).to eq(6)
        expect(rate.data[:accessorials]).to eq([
          { "code" => "ARMCF", "cost" => 148.72, "name" => "MANHATTAN CONGESTION FEE" },
          { "code" => "GUARANTEE", "cost" => 378.03, "name" => "Guaranteed Service" }
        ])
      end

      it "has correct rate details for TForce rate" do
        rate = rates.value!.data.fourth
        expect(rate.total_amount).to eq(Money.new(344_179, "USD"))
        expect(rate.data[:carrier_code]).to eq("TFXF")
        expect(rate.data[:carrier_name]).to eq("TForce Freight")
        expect(rate.data[:service_level]).to eq("TForce Freight LTL")
        expect(rate.data[:quote_number]).to eq("702593937")
        expect(rate.data[:estimated_transit_time]).to be_nil
        expect(rate.data[:accessorials]).to eq([])
      end
    end
  end
end
