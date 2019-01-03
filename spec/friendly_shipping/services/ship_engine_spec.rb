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
      end
    end

    context 'with an unsuccessful request', vcr: { cassette_name: 'shipengine/labels/failure' } do
      let(:service) { described_class.new(token: 'invalid_token') }

      it { is_expected.to be_a Dry::Monads::Failure }
    end
  end
end
