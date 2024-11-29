# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine do
  subject(:service) { described_class.new(token: ENV.fetch('SHIPENGINE_API_KEY', nil)) }

  it { is_expected.to respond_to(:carriers) }

  describe 'initialization' do
    it { is_expected.not_to respond_to :token }
  end

  describe 'client' do
    subject(:client) { service.send :client }

    it { is_expected.to be_a(FriendlyShipping::HttpClient) }
    it { expect(client.error_handler).to be_a(FriendlyShipping::ApiErrorHandler) }
    it { expect(client.error_handler.api_error_class).to eq(FriendlyShipping::Services::ShipEngine::ApiError) }
  end

  describe 'carriers' do
    subject { service.carriers }

    context 'with a successful request', vcr: { cassette_name: 'shipengine/carriers/success' } do
      it { is_expected.to be_a Dry::Monads::Success }
    end

    context 'with an unsuccessful request', vcr: { cassette_name: 'shipengine/carriers/failure' } do
      let(:service) { described_class.new(token: 'invalid_token') }

      it { is_expected.to be_a Dry::Monads::Failure }
    end
  end

  shared_examples "returns rate estimates" do
    let(:package) { FactoryBot.build(:physical_package) }
    let(:origin) { FactoryBot.build(:physical_location, zip: '78756') }
    let(:destination) { FactoryBot.build(:physical_location, zip: '91521') }
    let(:shipment) { FactoryBot.build(:physical_shipment, origin: origin, destination: destination) }
    let(:carriers) { [service.carriers.value!.data.last] }
    let(:options) { FriendlyShipping::Services::ShipEngine::RateEstimatesOptions.new(carriers: carriers) }

    subject { service.rate_estimates(shipment, options: options) }

    it 'returns Physical::Rate objects wrapped in a Success Monad', vcr: { cassette_name: 'shipengine/rate_estimates/success' } do
      aggregate_failures do
        is_expected.to be_success
        expect(subject.value!.data).to be_a(Array)
        expect(subject.value!.data.first).to be_a(FriendlyShipping::Rate)
        expect(subject.value!.original_request).to be nil
        expect(subject.value!.original_response).to be nil
      end
    end

    context 'with debug set to true' do
      subject { service.rate_estimates(shipment, options: options, debug: true) }

      it 'returns original request and response along with the data', vcr: { cassette_name: 'shipengine/rate_estimates/success' } do
        aggregate_failures do
          is_expected.to be_success
          expect(subject.value!.data).to be_a(Array)
          expect(subject.value!.data.first).to be_a(FriendlyShipping::Rate)
          expect(subject.value!.original_request).to be_present
          expect(subject.value!.original_response).to be_present
        end
      end
    end

    context 'when not specifying carriers' do
      let(:options) { FriendlyShipping::Services::ShipEngine::RateEstimatesOptions.new }

      it 'fails' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end

    context 'with a super heavy package', vcr: { cassette_name: 'shipengine/rate_estimates/overweight' } do
      let(:package) { FactoryBot.build(:physical_package, items: FactoryBot.build_list(:physical_item, 900 )) }
      let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package], origin: origin, destination: destination) }

      it 'returns a failure with error messages' do
        aggregate_failures do
          is_expected.to be_failure
          expect(subject.failure.to_s).to eq("[\"Error calculating rates for one or more mail classes: There are no rates available for the package information provided. Error encountered (Log ID: 33439)\"]")
        end
      end
    end
  end

  describe "rate_estimates" do
    it_behaves_like "returns rate estimates"
  end

  describe "timings" do
    it_behaves_like "returns rate estimates"
  end

  describe 'rates' do
    let(:package) { FactoryBot.build(:physical_package, items: FactoryBot.build_list(:physical_item, 3, description: "Broom", cost: Money.new(2500, 'USD'), weight: Measured::Weight.new(7, "pounds"))) }
    let(:origin) { FactoryBot.build(:physical_location, zip: '78756') }
    let(:country) { Carmen::Country.named("Canada") }
    let(:destination) { FactoryBot.build(:physical_location, country: country, region: country.subregions.coded("AB"), address1: '123 4 Ave', zip: 'T0A3J0') }
    let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package], origin: origin, destination: destination, service_code: 'apc_priority_ddp_delcon' ) }
    let(:service_code) { "apc_priority_ddp_delcon" }
    let(:carriers) { [service.carriers.value!.data.last] }
    let(:rates_options) { FriendlyShipping::Services::ShipEngine::RatesOptions.new(carriers: carriers, service_code: service_code, package_options: [rates_package_options]) }
    let(:rates_package_options) { FriendlyShipping::Services::ShipEngine::RatesPackageOptions.new(package_id: package.id, item_options: rates_item_options) }
    let(:rates_item_options) do
      [
        FriendlyShipping::Services::ShipEngine::RatesItemOptions.new(
          item_id: package.items.first.id,
          country_of_origin: "US",
          commodity_code: "9603-10-0000",
        )
      ]
    end

    subject { service.rates(shipment, options: rates_options) }

    it 'returns Physical::Rate objects wrapped in a Success Monad', vcr: { cassette_name: 'shipengine/rates/success' } do
      aggregate_failures do
        is_expected.to be_success
        expect(subject.value!.data).to be_a(Array)
        expect(subject.value!.data.first).to be_a(FriendlyShipping::Rate)
        expect(subject.value!.original_request).to be nil
        expect(subject.value!.original_response).to be nil
      end
    end

    context 'with debug set to true' do
      subject { service.rates(shipment, options: rates_options, debug: true) }

      it 'returns original request and response along with the data', vcr: { cassette_name: 'shipengine/rates/success' } do
        aggregate_failures do
          is_expected.to be_success
          expect(subject.value!.data).to be_a(Array)
          expect(subject.value!.data.first).to be_a(FriendlyShipping::Rate)
          expect(subject.value!.original_request).to be_present
          expect(subject.value!.original_response).to be_present
        end
      end
    end

    context 'when not specifying carriers' do
      let(:rates_options) { FriendlyShipping::Services::ShipEngine::RatesOptions.new }

      it 'fails' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end

    context 'with a super heavy package', vcr: { cassette_name: 'shipengine/rates/overweight' } do
      let(:package) { FactoryBot.build(:physical_package, items: FactoryBot.build_list(:physical_item, 30, description: "Broom", cost: Money.new(2500, 'USD'), weight: Measured::Weight.new(7, "pounds"))) }
      let(:origin) { FactoryBot.build(:physical_location, zip: '78756') }
      let(:country) { Carmen::Country.named("Canada") }
      let(:destination) { FactoryBot.build(:physical_location, country: country, region: country.subregions.coded("AB"), address1: '123 4 Ave', zip: 'T0A3J0') }
      let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package], origin: origin, destination: destination, service_code: 'apc_priority_ddp_delcon' ) }
      let(:service_code) { "apc_priority_ddp_delcon" }
      let(:carriers) { [service.carriers.value!.data.last] }
      let(:options) { FriendlyShipping::Services::ShipEngine::RatesOptions.new(carriers: carriers, service_code: service_code) }

      it 'returns a failure with error messages' do
        aggregate_failures do
          is_expected.to be_failure
          expect(subject.failure.to_s).to eq("A shipping carrier error occurred: Unable to determine base rate from rate chart. (Weight: 210.3798, zone: CA, country: CA)")
        end
      end
    end
  end

  describe 'labels' do
    let(:package) { FactoryBot.build(:physical_package) }
    let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package]) }
    let(:carrier) { FriendlyShipping::Carrier.new(id: ENV.fetch('SHIPENGINE_CARRIER_ID', nil)) }
    let(:shipping_method) { FriendlyShipping::ShippingMethod.new(service_code: "usps_priority_mail", carrier: carrier) }
    let(:options) do
      FriendlyShipping::Services::ShipEngine::LabelOptions.new(
        shipping_method: shipping_method,
        package_options: package_options
      )
    end
    let(:package_options) do
      [
        FriendlyShipping::Services::ShipEngine::LabelPackageOptions.new(
          package_id: package.id
        )
      ]
    end

    subject(:labels) { service.labels(shipment, options: options) }

    context 'with a successful request', vcr: { cassette_name: 'shipengine/labels/success' } do
      it { is_expected.to be_a Dry::Monads::Success }

      context "when unwrapped" do
        subject { labels.value!.data }
        let(:label) { subject.first }

        it { is_expected.to be_a Array }

        it "contains a valid label object" do
          expect(label).to be_a(FriendlyShipping::Label)
        end

        it "has a valid URL" do
          expect(label.label_href).to start_with("https://")
        end

        it "has the right format" do
          expect(label.label_format).to eq(:pdf)
        end
      end

      context 'with debug set to true' do
        subject(:labels) { service.labels(shipment, options: options, debug: true) }

        it 'returns original request and response along with the data' do
          aggregate_failures do
            is_expected.to be_success
            expect(subject.value!.data).to be_a(Array)
            expect(subject.value!.data.first).to be_a(FriendlyShipping::Label)
            expect(subject.value!.original_request).to be_present
            expect(subject.value!.original_response).to be_present
          end
        end
      end
    end

    context 'when requesting an inline label', vcr: { cassette_name: 'shipengine/labels/success_inline_label' } do
      let(:options) do
        FriendlyShipping::Services::ShipEngine::LabelOptions.new(
          shipping_method: shipping_method,
          label_download_type: :inline,
          label_format: :zpl
        )
      end

      it { is_expected.to be_a Dry::Monads::Success }

      context "when unwrapped" do
        subject { labels.value!.data }
        let(:label) { subject.first }

        it { is_expected.to be_a Array }

        it "contains a valid label object" do
          expect(label).to be_a(FriendlyShipping::Label)
        end

        it "does not have a URL" do
          expect(label.label_href).to be nil
        end

        it "has label data" do
          expect(label.label_data).to match(/.*\^XA.*\^XZ.*/m)
        end

        it "has the right format" do
          expect(label.label_format).to eq(:zpl)
        end
      end
    end

    context 'with a shipment specifying a large flat rate box', vcr: { cassette_name: 'shipengine/labels/flat_rate_box_success' } do
      let(:package_options) do
        [
          FriendlyShipping::Services::ShipEngine::LabelPackageOptions.new(
            package_id: package.id,
            package_code: :large_flat_rate_box
          )
        ]
      end

      it { is_expected.to be_a Dry::Monads::Success }

      context "when unwrapped" do
        subject { labels.value!.data }
        let(:label) { subject.first }

        it { is_expected.to be_a Array }

        it "contains a valid label object with a URL" do
          expect(label).to be_a(FriendlyShipping::Label)
          expect(label.label_href).to start_with("https://")
          expect(label.label_format).to eq(:pdf)
          expect(label.cost).to eq(0.0)
          expect(label.shipment_cost).to eq(0.0)
        end
      end
    end

    context 'with a shipment specifying a reference numbers', vcr: { cassette_name: 'shipengine/labels/reference_number_success' } do
      let(:options) do
        FriendlyShipping::Services::ShipEngine::LabelOptions.new(
          shipping_method: shipping_method,
          label_download_type: :inline,
          label_format: :zpl,
          package_options: package_options
        )
      end

      let(:package_options) do
        [
          FriendlyShipping::Services::ShipEngine::LabelPackageOptions.new(
            package_id: package.id,
            messages: [
              "Wer ist John Maynard?",
              "John Maynard war unser Steuermann",
              "aus hielt er, bis er das Ufer gewann"
            ]
          ),
        ]
      end

      it { is_expected.to be_a Dry::Monads::Success }

      context "when unwrapped" do
        subject { labels.value!.data }
        let(:label) { subject.first }

        it { is_expected.to be_a Array }

        it "contains a valid label object" do
          expect(label).to be_a(FriendlyShipping::Label)
        end

        it "has the right format" do
          expect(label.label_format).to eq(:zpl)
        end

        it 'contains the reference numbers' do
          expect(label.label_data).to match("Wer ist John Maynard?")
          expect(label.label_data).to match("John Maynard war unser Steuermann")
          expect(label.label_data).to match("aus hielt er, bis er das Ufer gewann")
        end
      end
    end

    context 'with a shipment specifying an invalid package code', vcr: { cassette_name: 'shipengine/labels/invalid_box_failure' } do
      let(:package_options) do
        [
          FriendlyShipping::Services::ShipEngine::LabelPackageOptions.new(
            package_id: package.id,
            package_code: :not_a_usps_package_code
          ),
        ]
      end

      it { is_expected.to be_a Dry::Monads::Failure }

      context "when unwrapped" do
        subject { labels.failure }

        it { is_expected.to be_a FriendlyShipping::ApiResult }

        it "converts to an understandable error message" do
          expect(subject.to_s).to eq("invalid package_code 'not_a_usps_package_code'")
        end
      end
    end

    context 'with an unsuccessful request', vcr: { cassette_name: 'shipengine/labels/failure' } do
      let(:service) { described_class.new(token: 'invalid_token') }

      it { is_expected.to be_a Dry::Monads::Failure }

      it "returns an understandable error string" do
        expect(subject.failure.to_s).to eq("401 Unauthorized")
      end
    end
  end

  describe 'void' do
    let(:label) { FriendlyShipping::Label.new(id: label_id) }

    subject { service.void(label) }

    let(:label_id) { "se-123456" }
    let(:response) { instance_double('RestClient::Response', code: 200, body: response_body.to_json, headers: {}) }

    before do
      expect(RestClient).to receive(:put).
        with("https://api.shipengine.com/v1/labels/se-123456/void", "", service.send(:request_headers)).
        and_return(response)
    end

    context 'with a voidable label' do
      let(:response_body) do
        {
          approved: true,
          message: "Request for refund submitted.  This label has been voided."
        }
      end

      it 'returns a success Monad' do
        expect(subject).to be_success
      end
    end

    context 'with an unvoidable label' do
      let(:response_body) do
        {
          approved: false,
          message: "Could not void this label for some reason"
        }
      end

      it 'returns a failure Monad' do
        expect(subject).to be_failure
      end
    end
  end

  describe "validate_address", vcr: { cassette_name: "shipengine/validate_address/success" } do
    subject(:validate_address) { service.validate_address(location) }

    let(:location) do
      Physical::Location.new(
        company_name: "ACME Inc",
        name: "John Smith",
        email: "john@acme.com",
        phone: "123-123-1234",
        address1: "123 Maple St",
        address2: "Suite 456",
        city: "Richmond",
        zip: "23224",
        region: "VA",
        country: "US",
        address_type: "residential"
      )
    end

    it { is_expected.to be_a Dry::Monads::Success }
  end
end
