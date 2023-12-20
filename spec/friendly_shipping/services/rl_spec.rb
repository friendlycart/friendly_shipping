# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL do
  subject(:service) { described_class.new(api_key: ENV.fetch('RL_API_KEY', nil)) }

  describe "initialization" do
    it { is_expected.to respond_to :api_key }
    it { is_expected.to respond_to :test }
    it { is_expected.to respond_to :client }
  end

  describe 'client' do
    subject(:client) { service.client }

    it { is_expected.to be_a(FriendlyShipping::HttpClient) }
    it { expect(client.error_handler).to be_a(FriendlyShipping::ApiErrorHandler) }
    it { expect(client.error_handler.api_error_class).to eq(FriendlyShipping::Services::RL::ApiError) }
  end

  let(:shipment) do
    FactoryBot.build(
      :physical_shipment,
      origin: origin,
      destination: destination
    )
  end

  let(:origin) do
    FactoryBot.build(
      :physical_location,
      company_name: "ACME Inc",
      address1: "123 Maple St",
      address2: "Suite 100",
      city: "New York",
      region: "NY",
      zip: "10001",
      phone: "123-123-1234",
      email: "acme@example.com"
    )
  end

  let(:destination) do
    FactoryBot.build(
      :physical_location,
      company_name: "Widgets LLC",
      address1: "456 Oak St",
      address2: "Suite 200",
      city: "Boulder",
      region: "CO",
      zip: "80301",
      phone: "321-321-3210",
      email: "widgets@example.com"
    )
  end

  let(:options) do
    FriendlyShipping::Services::RL::RateQuoteOptions.new(
      pickup_date: Time.now,
      additional_service_codes: %w[Hazmat],
      package_options: shipment.packages.map do |package|
        FriendlyShipping::Services::RL::PackageOptions.new(
          package_id: package.id,
          item_options: package.items.map do |item|
            FriendlyShipping::Services::RL::ItemOptions.new(
              item_id: item.id,
              freight_class: "92.5"
            )
          end
        )
      end
    )
  end

  describe "#create_bill_of_lading" do
    subject { service.create_bill_of_lading(shipment, options: options) }

    let(:shipment) do
      FactoryBot.build(
        :physical_shipment,
        origin: origin,
        destination: destination,
        structures: [pallet],
        packages: nil
      )
    end
    let(:pallet) do
      FactoryBot.build(
        :physical_structure,
        id: "pallet",
        packages: [package_1, package_2]
      )
    end

    let(:package_1) do
      FactoryBot.build(
        :physical_package,
        id: "package 1",
        description: "Wicks",
        items: [
          Physical::Item.new(
            weight: Measured::Weight(50, :g)
          )
        ],
        container: Physical::Box.new(
          dimensions: [
            Measured::Length(1, :cm),
            Measured::Length(2, :cm),
            Measured::Length(3, :cm)
          ]
        )
      )
    end

    let(:package_2) do
      FactoryBot.build(
        :physical_package,
        id: "package 2",
        description: "Tumblers",
        items: [
          Physical::Item.new(
            weight: Measured::Weight(50, :g)
          )
        ],
        container: Physical::Box.new(
          dimensions: [
            Measured::Length(1, :cm),
            Measured::Length(2, :cm),
            Measured::Length(3, :cm)
          ]
        )
      )
    end

    let(:options) do
      FriendlyShipping::Services::RL::BOLOptions.new(
        pickup_time_window: 1.hour.ago..1.hour.from_now,
        additional_service_codes: %w[OriginLiftgate],
        structure_options: shipment.structures.map do |structure|
          FriendlyShipping::Services::RL::StructureOptions.new(
            structure_id: structure.id,
            package_options: structure.packages.map do |package|
              FriendlyShipping::Services::RL::PackageOptions.new(
                package_id: package.id,
                nmfc_primary_code: "87700",
                nmfc_sub_code: "07",
                freight_class: "92.5"
              )
            end
          )
        end,
        packages_serializer: nil
      )
    end

    context "with a successful request", vcr: { cassette_name: "rl/create_bill_of_lading/success" } do
      it { is_expected.to be_a Dry::Monads::Success }

      it "has all the right data" do
        result = subject.value!.data
        expect(result).to be_a(FriendlyShipping::Services::RL::ShipmentInformation)
        expect(result.pro_number).to eq("WP7506414")
        expect(result.pickup_request_number).to eq("74201384")
      end
    end

    context "with an unsuccessful request", vcr: { cassette_name: "rl/create_bill_of_lading/failure" } do
      # Request will fail with no packages provided
      let(:shipment) { FactoryBot.build(:physical_shipment, packages: []) }

      it { is_expected.to be_a Dry::Monads::Failure }
      it { expect(subject.failure.data).to be_a FriendlyShipping::Services::RL::ApiError }
      it { expect(subject.failure.data.message).to include("There must be at least one item in the list") }
    end

    describe "deprecated packages behavior" do
      # TODO: Remove when packages_serializer is removed

      let(:shipment) do
        FactoryBot.build(
          :physical_shipment,
          origin: origin,
          destination: destination
        )
      end

      let(:options) do
        FriendlyShipping::Services::RL::BOLOptions.new(
          pickup_time_window: 1.hour.ago..1.hour.from_now,
          additional_service_codes: %w[OriginLiftgate],
          package_options: shipment.packages.map do |package|
            FriendlyShipping::Services::RL::PackageOptions.new(
              package_id: package.id,
              item_options: package.items.map do |item|
                FriendlyShipping::Services::RL::ItemOptions.new(
                  item_id: item.id,
                  nmfc_primary_code: "87700",
                  nmfc_sub_code: "07",
                  freight_class: "92.5"
                )
              end
            )
          end
        )
      end

      context "with a successful request", vcr: { cassette_name: "rl/create_bill_of_lading/success" } do
        it { is_expected.to be_a Dry::Monads::Success }

        it "has all the right data" do
          result = subject.value!.data
          expect(result).to be_a(FriendlyShipping::Services::RL::ShipmentInformation)
          expect(result.pro_number).to eq("WP7506414")
          expect(result.pickup_request_number).to eq("74201384")
        end
      end

      context "with an unsuccessful request", vcr: { cassette_name: "rl/create_bill_of_lading/failure" } do
        # Request will fail with no packages provided
        let(:shipment) { FactoryBot.build(:physical_shipment, packages: []) }

        it { is_expected.to be_a Dry::Monads::Failure }
        it { expect(subject.failure.data).to be_a FriendlyShipping::Services::RL::ApiError }
        it { expect(subject.failure.data.message).to include("There must be at least one item in the list") }
      end
    end
  end

  describe "#print_bill_of_lading" do
    subject { service.print_bill_of_lading(shipment_info) }

    let(:shipment_info) do
      FriendlyShipping::Services::RL::ShipmentInformation.new(
        pro_number: "WP7630587"
      )
    end

    context "with a successful request", vcr: { cassette_name: "rl/print_bill_of_lading/success" } do
      it { is_expected.to be_a Dry::Monads::Success }

      it "has all the right data" do
        result = subject.value!.data
        expect(result).to be_a(FriendlyShipping::Services::RL::ShipmentDocument)
        expect(result.format).to eq(:pdf)
        expect(result.document_type).to eq(:rl_bol)
        expect(result.binary).to start_with("%PDF-")
        expect(shipment_info.documents).to include(result)
      end
    end
  end

  describe "#print_shipping_labels" do
    subject { service.print_shipping_labels(shipment_info) }

    let(:shipment_info) do
      FriendlyShipping::Services::RL::ShipmentInformation.new(
        pro_number: "WP7630587"
      )
    end

    context "with a successful request", vcr: { cassette_name: "rl/print_shipping_labels/success" } do
      it { is_expected.to be_a Dry::Monads::Success }

      it "has all the right data" do
        result = subject.value!.data
        expect(result).to be_a(FriendlyShipping::Services::RL::ShipmentDocument)
        expect(result.format).to eq(:pdf)
        expect(result.document_type).to eq(:label)
        expect(result.binary).to start_with("%PDF-")
        expect(shipment_info.documents).to include(result)
      end
    end
  end

  describe "#rate_quote" do
    subject { service.rate_quote(shipment, options: options) }

    context "with a successful request", vcr: { cassette_name: "rl/rate_quote/success" } do
      it { is_expected.to be_a Dry::Monads::Success }

      it "has all the right data" do
        rates = subject.value!.data
        expect(rates.length).to eq(2)

        rate = rates.first
        expect(rate).to be_a(FriendlyShipping::Rate)
        expect(rate.total_amount).to eq(Money.new(43_671, "USD"))
        expect(rate.shipping_method.name).to eq("Standard Service")
        expect(rate.shipping_method.service_code).to eq("STD")

        rate = rates.last
        expect(rate).to be_a(FriendlyShipping::Rate)
        expect(rate.total_amount).to eq(Money.new(48_801, "USD"))
        expect(rate.shipping_method.name).to eq("Guaranteed Service")
        expect(rate.shipping_method.service_code).to eq("GSDS")
      end
    end

    context "with an unsuccessful request", vcr: { cassette_name: "rl/rate_quote/failure" } do
      # Request will fail with no packages provided
      let(:shipment) { FactoryBot.build(:physical_shipment, packages: []) }

      it { is_expected.to be_a Dry::Monads::Failure }
      it { expect(subject.failure.data).to be_a FriendlyShipping::Services::RL::ApiError }
      it { expect(subject.failure.data.message).to include("At least one Item is required") }
    end
  end

  describe "#transit_times" do
    subject { service.transit_times(shipment, options: options) }

    context "with a successful request", vcr: { cassette_name: "rl/transit_times/success" } do
      it { is_expected.to be_a Dry::Monads::Success }

      it "has all the right data" do
        rates = subject.value!.data
        expect(rates.length).to eq(1)

        rate = rates.first
        expect(rate).to be_a(FriendlyShipping::Timing)
        expect(rate.pickup).to eq(Time.parse("2023-08-04"))
        expect(rate.delivery).to eq(Time.parse("2023-08-14"))
        expect(rate.guaranteed).to be(false)
        expect(rate.data).to eq(days_in_transit: 6)
        expect(rate.shipping_method.name).to eq("Standard Service")
        expect(rate.shipping_method.service_code).to eq("STD")
      end
    end

    context "with an unsuccessful request", vcr: { cassette_name: "rl/transit_times/failure" } do
      # Request will fail when destination zip is missing
      let(:destination) { FactoryBot.build(:physical_location, zip: nil) }

      it { is_expected.to be_a Dry::Monads::Failure }
      it { expect(subject.failure.data).to be_a FriendlyShipping::Services::RL::ApiError }
      it { expect(subject.failure.data.message).to include("ServicePoint Zip code is required and cannot be null or empty") }
    end
  end

  describe "#get_invoice" do
    subject { service.get_invoice(pro_number) }
    let(:pro_number) { "WP9974772" }

    context "with a successful request", vcr: { cassette_name: "rl/get_invoice/success" } do
      it { is_expected.to be_a Dry::Monads::Success }

      it "has all the right data" do
        result = subject.value!.data
        expect(result).to be_a(FriendlyShipping::Services::RL::ShipmentDocument)
        expect(result.format).to eq(:pdf)
        expect(result.binary).to start_with("JVB")
      end
    end
  end
end
