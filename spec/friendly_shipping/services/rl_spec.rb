# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL do
  subject(:service) { described_class.new(api_key: ENV['RL_API_KEY']) }

  describe "initialization" do
    it { is_expected.to respond_to :api_key }
    it { is_expected.to respond_to :test }
    it { is_expected.to respond_to :client }
  end

  describe "#rate_quote" do
    subject { service.rate_quote(shipment, options: options) }

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
        city: "New York",
        region: "NY",
        zip: "10001"
      )
    end

    let(:destination) do
      FactoryBot.build(
        :physical_location,
        city: "Boulder",
        region: "CO",
        zip: "80301"
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
      it { expect(subject.failure.data).to be_a FriendlyShipping::Services::RL::BadRequest }
      it { expect(subject.failure.data.message).to include("At least one Item is required") }
    end
  end
end
