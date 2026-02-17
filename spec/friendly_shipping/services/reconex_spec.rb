# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Reconex do
  subject(:service) do
    described_class.new(
      api_key: "test-api-key",
      live_api_base: "https://live.example.com",
      test_api_base: "https://test.example.com"
    )
  end

  describe "initialization" do
    it { is_expected.to respond_to :api_key }
    it { is_expected.to respond_to :test }
    it { is_expected.to respond_to :live_api_base }
    it { is_expected.to respond_to :test_api_base }
    it { is_expected.to respond_to :client }
  end

  describe 'client' do
    subject(:client) { service.client }

    it { is_expected.to be_a(FriendlyShipping::HttpClient) }
    it { expect(client.error_handler).to be_a(FriendlyShipping::ApiErrorHandler) }
    it { expect(client.error_handler.api_error_class).to eq(FriendlyShipping::Services::Reconex::ApiError) }
  end

  describe "#rate_quote" do
    subject(:rate_quote) { service.rate_quote(shipment, options: options) }

    let(:shipment) { Physical::Shipment.new(structures: structures, origin: origin, destination: destination) }

    let(:origin) do
      Physical::Location.new(
        address1: "1910 S McCarran Blvd",
        city: "Reno",
        zip: "89502",
        region: "NV",
        country: "US"
      )
    end

    let(:destination) do
      Physical::Location.new(
        address1: "813 Kincross Dr",
        city: "Boulder",
        zip: "80501",
        region: "CO",
        country: "US"
      )
    end

    let(:structures) { [structure] }

    let(:structure) do
      Physical::Structure.new(
        id: "structure_1",
        packages: [package]
      )
    end

    let(:package) do
      Physical::Package.new(
        id: "package_1",
        items: [item],
        dimensions: [
          Measured::Length(16, :in),
          Measured::Length(14, :in),
          Measured::Length(13, :in)
        ]
      )
    end

    let(:item) do
      Physical::Item.new(
        id: "item_1",
        weight: Measured::Weight(46.5, :lb)
      )
    end

    let(:options) do
      FriendlyShipping::Services::Reconex::QuoteOptions.new(
        dock_type: "BusinessWithDock",
        total_quantity: "1",
        total_units: "Pallets",
        structure_options: [
          FriendlyShipping::Services::Reconex::StructureOptions.new(
            structure_id: "structure_1",
            package_options: [
              FriendlyShipping::Services::Reconex::PackageOptions.new(
                package_id: "package_1",
                freight_class: "70",
                nmfc_code: "199620",
                packaging: "Pallets",
                description: "Golden Brands 464 Soy Wax"
              )
            ]
          )
        ]
      )
    end

    context "with a successful response" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "reconex", "quote", "success.json")) }

      let(:response) do
        instance_double(
          RestClient::Response,
          code: 200,
          body: response_body,
          headers: {}
        )
      end

      before do
        expect(RestClient).to receive(:post).and_return(response)
      end

      it { is_expected.to be_success }

      it "returns an array of rates" do
        rates = rate_quote.value!.data
        expect(rates.length).to eq(2)
        expect(rates).to all(be_a(FriendlyShipping::Rate))
      end

      it "has the correct total for the first rate" do
        rate = rate_quote.value!.data.first
        expect(rate.total_amount).to eq(Money.new(43_800, "USD"))
      end

      it "has the correct carrier for the first rate" do
        rate = rate_quote.value!.data.first
        expect(rate.shipping_method.name).to eq("R&L Carriers")
        expect(rate.shipping_method.service_code).to eq("RLCA")
      end

      it "has the correct total for the second rate" do
        rate = rate_quote.value!.data.last
        expect(rate.total_amount).to eq(Money.new(73_519, "USD"))
      end

      it "has cost breakdown data" do
        rate = rate_quote.value!.data.first
        expect(rate.data[:base]).to eq(275.0)
        expect(rate.data[:fsc]).to eq(33.0)
        expect(rate.data[:access]).to eq(130.0)
      end

      it "has transit time data" do
        rate = rate_quote.value!.data.first
        expect(rate.data[:transit_time]).to eq("2")
      end
    end

    context "with an error response" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "reconex", "quote", "failure.json")) }

      let(:response) do
        instance_double(
          RestClient::Response,
          code: 200,
          body: response_body,
          headers: {}
        )
      end

      before do
        expect(RestClient).to receive(:post).and_return(response)
      end

      it { is_expected.to be_failure }

      it "returns error messages" do
        expect(rate_quote.failure.data).to include("Origin postal code is required")
      end
    end
  end

  describe "#create_load" do
    subject(:create_load) { service.create_load(shipment, options: options) }

    let(:shipment) { Physical::Shipment.new(structures: structures, origin: origin, destination: destination) }

    let(:origin) do
      Physical::Location.new(
        company_name: "Widgets Inc.",
        name: "The Shipping Department",
        address1: "1910 S McCarran Blvd",
        city: "Reno",
        zip: "89502",
        region: "NV",
        country: "US",
        phone: "888-973-0223",
        email: "support@widgets.com"
      )
    end

    let(:destination) do
      Physical::Location.new(
        company_name: "ACME Inc.",
        name: "John Smith",
        address1: "813 Kincross Dr",
        city: "Boulder",
        zip: "80501",
        region: "CO",
        country: "US",
        phone: "3366682999",
        email: "john@acme.com"
      )
    end

    let(:structures) { [structure] }

    let(:structure) do
      Physical::Structure.new(
        id: "structure_1",
        packages: [package]
      )
    end

    let(:package) do
      Physical::Package.new(
        id: "package_1",
        items: [item],
        dimensions: [
          Measured::Length(16, :in),
          Measured::Length(14, :in),
          Measured::Length(13, :in)
        ]
      )
    end

    let(:item) do
      Physical::Item.new(
        id: "item_1",
        weight: Measured::Weight(46.5, :lb)
      )
    end

    let(:options) do
      FriendlyShipping::Services::Reconex::LoadOptions.new(
        account_id: 1140,
        scac: "UPGF",
        rate: true,
        pro_number_requested: true,
        dispatch: true,
        structure_options: [
          FriendlyShipping::Services::Reconex::StructureOptions.new(
            structure_id: "structure_1",
            package_options: [
              FriendlyShipping::Services::Reconex::PackageOptions.new(
                package_id: "package_1",
                freight_class: "70",
                nmfc_code: "199620",
                packaging: "Pallets",
                description: "Golden Brands 464 Soy Wax"
              )
            ]
          )
        ]
      )
    end

    context "with a successful response" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "reconex", "create_load", "success.json")) }

      let(:response) do
        instance_double(
          RestClient::Response,
          code: 200,
          body: response_body,
          headers: {}
        )
      end

      before do
        expect(RestClient).to receive(:post).and_return(response)
      end

      it { is_expected.to be_success }

      it "returns a ShipmentInformation" do
        info = create_load.value!.data
        expect(info).to be_a(FriendlyShipping::Services::Reconex::ShipmentInformation)
      end

      it "has the correct load_id" do
        info = create_load.value!.data
        expect(info.load_id).to eq("3310514")
      end

      it "has the correct billing_id" do
        info = create_load.value!.data
        expect(info.billing_id).to eq("2223606199")
      end
    end

    context "with an error response" do
      let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "reconex", "create_load", "failure.json")) }

      let(:response) do
        instance_double(
          RestClient::Response,
          code: 200,
          body: response_body,
          headers: {}
        )
      end

      before do
        expect(RestClient).to receive(:post).and_return(response)
      end

      it { is_expected.to be_failure }

      it "returns error messages" do
        expect(create_load.failure.data).to include("Origin postal code is required")
      end
    end
  end

  describe "test mode" do
    context "when test is true (default)" do
      it "uses the test API base URL" do
        expect(service.send(:api_base)).to eq("https://test.example.com")
      end
    end

    context "when test is false" do
      subject(:service) do
        described_class.new(
          api_key: "test-api-key",
          live_api_base: "https://live.example.com",
          test_api_base: "https://test.example.com",
          test: false
        )
      end

      it "uses the live API base URL" do
        expect(service.send(:api_base)).to eq("https://live.example.com")
      end
    end
  end
end
