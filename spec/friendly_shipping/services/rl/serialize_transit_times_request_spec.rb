# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::SerializeTransitTimesRequest do
  subject { described_class.call(shipment: shipment, options: options) }

  let(:shipment) do
    FactoryBot.build(
      :physical_shipment,
      origin: origin,
      destination: destination
    )
  end

  let(:options) do
    FriendlyShipping::Services::RL::RateQuoteOptions.new(
      pickup_date: Time.parse("2023-07-19 10:30:00 UTC"),
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

  it do
    is_expected.to eq(
      {
        PickupDate: "07/19/2023",
        Origin: {
          City: "New York",
          StateOrProvince: "NY",
          ZipOrPostalCode: "10001",
          CountryCode: "USA"
        },
        Destinations: [{
          City: "Boulder",
          StateOrProvince: "CO",
          ZipOrPostalCode: "80301",
          CountryCode: "USA"
        }]
      }
    )
  end
end
