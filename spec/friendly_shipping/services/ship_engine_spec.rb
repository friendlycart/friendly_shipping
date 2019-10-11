# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine do
  subject(:service) { described_class.new(token: ENV['SHIPENGINE_API_KEY']) }

  it { is_expected.to respond_to(:carriers) }

  describe 'initialization' do
    it { is_expected.not_to respond_to :token }
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

  describe 'rate_estimates' do
    let(:package) { FactoryBot.build(:physical_package) }
    let(:origin) { FactoryBot.build(:physical_location, zip: '78756') }
    let(:destination) { FactoryBot.build(:physical_location, zip: '91521') }
    let(:shipment) { FactoryBot.build(:physical_shipment, origin: origin, destination: destination) }

    subject { service.rate_estimates(shipment) }

    it 'returns Physical::Rate objects wrapped in a Success Monad', vcr: { cassette_name: 'shipengine/rate_estimates/success' } do
      aggregate_failures do
        is_expected.to be_success
        expect(subject.value!.data).to be_a(Array)
        expect(subject.value!.data.first).to be_a(FriendlyShipping::Rate)
      end
    end

    context 'when specifying carriers' do
      let(:carriers) { [service.carriers.value!.data.last] }

      subject { service.rate_estimates(shipment, carriers: carriers) }

      it 'returns Physical::Rate objects wrapped in a Success Monad',
         vcr: { cassette_name: 'shipengine/rate_estimates/success_with_one_carrier' } do
        aggregate_failures do
          is_expected.to be_success
          expect(subject.value!.data).to be_a(Array)
          expect(subject.value!.data.first).to be_a(FriendlyShipping::Rate)
        end
      end
    end
  end

  describe 'labels' do
    let(:package) { FactoryBot.build(:physical_package) }
    let(:shipment) { FactoryBot.build(:physical_shipment, service_code: "usps_priority_mail", packages: [package]) }

    subject(:labels) { service.labels(shipment) }

    context 'with a successful request', vcr: { cassette_name: 'shipengine/labels/success' } do
      it { is_expected.to be_a Dry::Monads::Success }

      context "when unwrapped" do
        subject { labels.value! }
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
    end

    context 'when requesting an inline label', vcr: { cassette_name: 'shipengine/labels/success_inline_label' } do
      let(:shipment) do
        FactoryBot.build(
          :physical_shipment,
          service_code: "usps_priority_mail",
          packages: [package],
          options: { label_download_type: "inline", label_format: "zpl" }
        )
      end

      it { is_expected.to be_a Dry::Monads::Success }

      context "when unwrapped" do
        subject { labels.value! }
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
      let(:container) { FactoryBot.build(:physical_box, properties: { usps_package_code: "large_flat_rate_box" }) }
      let(:package) { FactoryBot.build(:physical_package, container: container) }

      it { is_expected.to be_a Dry::Monads::Success }

      context "when unwrapped" do
        subject { labels.value! }
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
    end

    context 'with a shipment specifying a reference numbers', vcr: { cassette_name: 'shipengine/labels/reference_number_success' } do
      let(:shipment) do
        FactoryBot.build(
          :physical_shipment,
          service_code: "usps_priority_mail",
          packages: [package],
          options: { label_download_type: "inline", label_format: "zpl" }
        )
      end

      let(:container) do
        FactoryBot.build(
          :physical_box,
          properties: {
            usps_label_messages: {
              reference1: "Wer ist John Maynard?",
              reference2: "John Maynard war unser Steuermann",
              reference3: "aus hielt er, bis er das Ufer gewann"
            }
          }
        )
      end

      let(:package) { FactoryBot.build(:physical_package, container: container) }

      it { is_expected.to be_a Dry::Monads::Success }

      context "when unwrapped" do
        subject { labels.value! }
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
      let(:container) { FactoryBot.build(:physical_box, properties: { usps_package_code: "not_a_usps_package_code" }) }
      let(:package) { FactoryBot.build(:physical_package, container: container) }

      it { is_expected.to be_a Dry::Monads::Failure }

      context "when unwrapped" do
        subject { labels.failure }

        it { is_expected.to be_a FriendlyShipping::BadRequest }

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
      expect(::RestClient).to receive(:put).
        with("https://api.shipengine.com/v1/labels/se-123456/void", "", service.send(:request_headers)).
        and_return(response)
    end

    context 'with a voidable label' do
      let(:response_body) do
        {
          "approved": true,
          "message": "Request for refund submitted.  This label has been voided."
        }
      end

      it 'returns a success Monad' do
        expect(subject).to be_success
      end
    end

    context 'with an unvoidable label' do
      let(:response_body) do
        {
          "approved": false,
          "message": "Could not void this label for some reason"
        }
      end

      it 'returns a failure Monad' do
        expect(subject).to be_failure
      end
    end
  end
end
