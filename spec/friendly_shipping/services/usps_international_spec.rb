# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/usps/timing_options'

RSpec.describe FriendlyShipping::Services::UspsInternational do
  subject(:service) { described_class.new(login: ENV['USPS_LOGIN']) }

  describe 'rate_estimates' do
    let(:country) { Carmen::Country.named("Canada") }
    let(:destination) { FactoryBot.build(:physical_location, country: country, region: country.subregions.coded("AB"), address1: '15 7 Ave', zip: 'T0A3J0') }
    let(:origin) { FactoryBot.build(:physical_location, region: "NC", zip: '27704') }
    let(:weight) { Measured::Weight(48, :ounces) }
    let(:dimensions) { [15, 10, 10].map { |e| Measured::Length(e, :inches) } }
    let(:packages) do
      [
        FactoryBot.build(:physical_package, container: nil, dimensions: dimensions, id: '0', weight: weight),
      ]
    end
    let(:shipment) { FactoryBot.build(:physical_shipment, packages: packages, origin: origin, destination: destination) }

    subject { service.rate_estimates(shipment, debug: true) }

    it 'returns Physical::Rate objects wrapped in a Success Monad', vcr: { cassette_name: 'usps_international/rate_estimates/success' } do
      aggregate_failures do
        is_expected.to be_success
        expect(subject.value!.data).to be_a(Array)
        expect(subject.value!.data).to all(be_a(FriendlyShipping::Rate))
      end
    end
  end
end
