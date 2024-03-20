# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngineLTL do
  subject(:service) { described_class.new(token: ENV.fetch('SHIPENGINE_API_KEY', nil)) }

  let(:carrier_id) { ENV.fetch('SHIPENGINE_LTL_CARRIER_ID', nil) }
  let(:scac) { ENV.fetch('SHIPENGINE_LTL_CARRIER_SCAC', nil) }

  it { is_expected.to respond_to(:carriers) }

  describe 'initialization' do
    it { is_expected.not_to respond_to :token }
  end

  describe 'client' do
    subject(:client) { service.send :client }

    it { is_expected.to be_a(FriendlyShipping::HttpClient) }
    it { expect(client.error_handler).to be_a(FriendlyShipping::ApiErrorHandler) }
    it { expect(client.error_handler.api_error_class).to eq(FriendlyShipping::Services::ShipEngineLTL::ApiError) }
  end

  describe '#carriers' do
    subject { service.carriers }

    context 'with a successful request', vcr: { cassette_name: 'shipengine_ltl/carriers/success' } do
      it { is_expected.to be_a Dry::Monads::Success }
      it { expect(subject.value!.data[0]).to be_a FriendlyShipping::Carrier }
      it { expect(subject.value!.data[0].id).to eq('1fd96e9e-9a25-436a-8e11-c6e4500cb7de') }
      it { expect(subject.value!.data[0].name).to eq('UPS Freight') }
      it { expect(subject.value!.data[0].data).to eq({ countries: %w[CA MX US], features: %w[auto_pro connect documents quote scheduled_pickup spot_quote tracking], scac: scac }) }
    end

    context 'with an unsuccessful request', vcr: { cassette_name: 'shipengine_ltl/carriers/failure' } do
      let(:service) { described_class.new(token: 'invalid_token') }

      it { is_expected.to be_a Dry::Monads::Failure }
      it { expect(subject.failure.data.cause).to be_a RestClient::Unauthorized }
    end
  end

  describe '#connect_carrier' do
    let(:credentials) do
      {
        username: ENV.fetch('UPS_LOGIN', nil),
        password: ENV.fetch('UPS_PASSWORD', nil),
        key: ENV.fetch('UPS_KEY', nil),
        account_number: ENV.fetch('UPS_SHIPPER_NUMBER', nil)
      }
    end

    subject { service.connect_carrier(credentials, scac) }

    context 'with a successful request', vcr: { cassette_name: 'shipengine_ltl/connect_carrier/success' } do
      it { is_expected.to be_a Dry::Monads::Success }
      it { expect(subject.value!.data).to eq({ 'carrier_id' => carrier_id }) }
    end

    context 'with an unsuccessful request', vcr: { cassette_name: 'shipengine_ltl/connect_carrier/failure' } do
      let(:scac) { 'bogus' }

      it { is_expected.to be_a Dry::Monads::Failure }
      it { expect(subject.failure.data).to be_a FriendlyShipping::Services::ShipEngineLTL::ApiError }
      it { expect(subject.failure.data.message).to eq('Invalid carrier SCAC') }
    end
  end

  describe '#update_carrier' do
    let(:credentials) do
      {
        username: ENV.fetch('UPS_LOGIN', nil),
        password: ENV.fetch('UPS_PASSWORD', nil),
        key: ENV.fetch('UPS_KEY', nil),
        account_number: ENV.fetch('UPS_SHIPPER_NUMBER', nil)
      }
    end

    subject { service.update_carrier(credentials, scac, carrier_id) }

    context 'with a successful request', vcr: { cassette_name: 'shipengine_ltl/update_carrier/success' } do
      it { is_expected.to be_a Dry::Monads::Success }
      it { expect(subject.value!.data).to eq({ 'carrier_id' => carrier_id }) }
    end

    context 'with an unsuccessful request', vcr: { cassette_name: 'shipengine_ltl/update_carrier/failure' } do
      let(:carrier_id) { 'bogus' }

      it { is_expected.to be_a Dry::Monads::Failure }
      it { expect(subject.failure.data.cause).to be_a RestClient::Unauthorized }
    end
  end

  describe '#request_quote' do
    subject { service.request_quote(carrier_id, shipment, options) }

    let(:shipment) do
      FactoryBot.build(
        :physical_shipment,
        origin: FactoryBot.build(
          :physical_location,
          properties: {
            account_number: ENV.fetch('UPS_SHIPPER_NUMBER', nil)
          }
        ),
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
      FriendlyShipping::Services::ShipEngineLTL::QuoteOptions.new(
        service_code: 'stnd',
        pickup_date: Time.now,
        accessorial_service_codes: %w[LFTP IPU],
        structure_options: shipment.structures.map do |structure|
          FriendlyShipping::Services::ShipEngineLTL::StructureOptions.new(
            structure_id: structure.id,
            package_options: structure.packages.map do |package|
              FriendlyShipping::Services::ShipEngineLTL::PackageOptions.new(
                package_id: package.id,
                packaging_code: 'pkg',
                freight_class: '92.5',
                nmfc_code: '16030 sub 1'
              )
            end
          )
        end,
        packages_serializer_class: nil
      )
    end

    context 'with a successful request', vcr: { cassette_name: 'shipengine_ltl/request_quote/success' } do
      it { is_expected.to be_a Dry::Monads::Success }

      it 'has all the right data' do
        rates = subject.value!.data
        expect(rates.length).to eq(1)
        rate = rates.first
        expect(rate).to be_a(FriendlyShipping::Rate)
        expect(rate.total_amount).to eq(Money.new(307, 'USD'))
        expect(rate.shipping_method.name).to eq('Standard')
        expect(rate.shipping_method.service_code).to eq('stnd')
      end
    end

    context 'with an unsuccessful request', vcr: { cassette_name: 'shipengine_ltl/request_quote/failure' } do
      let(:carrier_id) { 'bogus' }

      it { is_expected.to be_a Dry::Monads::Failure }
      it { expect(subject.failure.data).to be_a FriendlyShipping::Services::ShipEngineLTL::ApiError }
      it { expect(subject.failure.data.message).to include('Invalid carrier_id. bogus is not a valid carrier_id.') }
    end

    describe "deprecated packages behavior" do
      # TODO: Remove when packages_serializer_class is removed

      let(:shipment) do
        FactoryBot.build(
          :physical_shipment,
          origin: FactoryBot.build(
            :physical_location,
            properties: {
              account_number: ENV.fetch('UPS_SHIPPER_NUMBER', nil)
            }
          )
        )
      end

      let(:options) do
        FriendlyShipping::Services::ShipEngineLTL::QuoteOptions.new(
          service_code: 'stnd',
          pickup_date: Time.now,
          accessorial_service_codes: %w[LFTP IPU],
          package_options: shipment.packages.map do |package|
            FriendlyShipping::Services::ShipEngineLTL::PackageOptions.new(
              package_id: package.id,
              item_options: package.items.map do |item|
                FriendlyShipping::Services::ShipEngineLTL::ItemOptions.new(
                  item_id: item.id,
                  packaging_code: 'pkg',
                  freight_class: '92.5',
                  nmfc_code: '16030 sub 1'
                )
              end
            )
          end
        )
      end

      context 'with a successful request', vcr: { cassette_name: 'shipengine_ltl/request_quote/success' } do
        it { is_expected.to be_a Dry::Monads::Success }

        it 'has all the right data' do
          rates = subject.value!.data
          expect(rates.length).to eq(1)
          rate = rates.first
          expect(rate).to be_a(FriendlyShipping::Rate)
          expect(rate.total_amount).to eq(Money.new(307, 'USD'))
          expect(rate.shipping_method.name).to eq('Standard')
          expect(rate.shipping_method.service_code).to eq('stnd')
        end
      end

      context 'with an unsuccessful request', vcr: { cassette_name: 'shipengine_ltl/request_quote/failure' } do
        let(:carrier_id) { 'bogus' }

        it { is_expected.to be_a Dry::Monads::Failure }
        it { expect(subject.failure.data).to be_a FriendlyShipping::Services::ShipEngineLTL::ApiError }
        it { expect(subject.failure.data.message).to include('Invalid carrier_id. bogus is not a valid carrier_id.') }
      end
    end
  end
end
