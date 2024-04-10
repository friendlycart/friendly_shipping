# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip::SerializeRateEstimatesRequest do
  subject(:call) { described_class.call(shipment: shipment, package: package, options: options) }

  let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package]) }

  let(:package) do
    FactoryBot.build(
      :physical_package,
      id: "package",
      container: container,
      items: [],
      void_fill_density: Measured::Density(0, :g_ml)
    )
  end

  let(:package_options) do
    FriendlyShipping::Services::USPSShip::RateEstimatePackageOptions.new(
      package_id: "package",
      processing_category: :machinable
    )
  end

  let(:container) do
    FactoryBot.build(
      :physical_box,
      dimensions: [24, 21.321539, 10].map { |e| Measured::Length(e, :cm) },
      weight: Measured::Weight.new(14.025, :ounces)
    )
  end

  let(:options) do
    FriendlyShipping::Services::USPSShip::RateEstimateOptions.new(
      shipping_method: shipping_method,
      mailing_date: Date.parse("2024-04-01"),
      package_options: [package_options]
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
      weight: 0.88,
      length: 9.45,
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

  context "with the wrong processing category" do
    let(:package_options) do
      FriendlyShipping::Services::USPSShip::RateEstimatePackageOptions.new(
        package_id: "package",
        processing_category: :non_machinable
      )
    end

    it "serializes the correct processing category" do
      expect(call).to match(hash_including(processingCategory: "MACHINABLE"))
    end
  end

  context "with a non-correctable processing category" do
    let(:package_options) do
      FriendlyShipping::Services::USPSShip::RateEstimatePackageOptions.new(
        package_id: "package",
        processing_category: :letters
      )
    end

    it "does not change the processing category" do
      expect(call).to match(hash_including(processingCategory: "LETTERS"))
    end
  end
end
