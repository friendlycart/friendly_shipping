# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip::SerializeRateEstimatesRequest do
  subject(:call) { described_class.call(shipment: shipment, options: options) }

  let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package_1, package_2]) }

  let(:package_1) { FactoryBot.build(:physical_package, container: container_1, items: [], void_fill_density: Measured::Density(0, :g_ml)) }
  let(:package_2) { FactoryBot.build(:physical_package, container: container_2, items: [], void_fill_density: Measured::Density(0, :g_ml)) }

  let(:container_1) do
    FactoryBot.build(
      :physical_box,
      dimensions: [24, 21.321539, 10].map { |e| Measured::Length(e, :cm) },
      weight: Measured::Weight.new(14.025, :ounces)
    )
  end

  let(:container_2) do
    FactoryBot.build(
      :physical_box,
      dimensions: [18, 10.4531, 5].map { |e| Measured::Length(e, :cm) },
      weight: Measured::Weight.new(3.852, :ounces)
    )
  end

  let(:options) do
    FriendlyShipping::Services::USPSShip::RateEstimateOptions.new(
      shipping_method: shipping_method,
      mailing_date: Date.parse("2024-04-01")
    )
  end

  let(:shipping_method) do
    FriendlyShipping::Services::USPSShip::SHIPPING_METHODS.find do |sm|
      sm.service_code == "USPS_GROUND_ADVANTAGE"
    end
  end

  it "serializes the request" do
    expect(call).to eq(
      originZIPCode: "20170",
      destinationZIPCode: "20170",
      weight: 1.12,
      length: 16.54,
      width: 8.39,
      height: 3.94,
      mailClass: "USPS_GROUND_ADVANTAGE",
      processingCategory: "MACHINABLE",
      rateIndicator: "DR",
      destinationEntryFacilityType: "NONE",
      priceType: "RETAIL",
      mailingDate: "2024-04-01"
    )
  end
end
