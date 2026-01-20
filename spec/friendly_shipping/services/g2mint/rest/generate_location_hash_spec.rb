# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::G2Mint::REST::GenerateLocationHash do
  describe ".call" do
    subject(:call) { described_class.call(location: location) }

    let(:location) do
      Physical::Location.new(
        address1: "123 Maple St",
        address2: "Suite 100",
        city: "Richmond",
        zip: "23224",
        region: "VA",
        country: "US"
      )
    end

    it do
      is_expected.to eq(
        address1: "123 Maple St",
        address2: "Suite 100",
        city: "Richmond",
        stateProvince: "VA",
        postalCode: "23224",
        country: "US"
      )
    end

    context "with missing values" do
      let(:location) do
        Physical::Location.new(
          city: nil,
          zip: "23224",
          region: "VA",
          country: "US"
        )
      end

      it "excludes nil values" do
        is_expected.to eq(
          stateProvince: "VA",
          postalCode: "23224",
          country: "US"
        )
      end
    end

    context "with latitude and longitude" do
      let(:location) do
        Physical::Location.new(
          city: "Richmond",
          zip: "23224",
          region: "VA",
          country: "US",
          latitude: 37.5407,
          longitude: -77.4360
        )
      end

      it "includes coordinates" do
        is_expected.to eq(
          city: "Richmond",
          stateProvince: "VA",
          postalCode: "23224",
          country: "US",
          latitude: 37.5407,
          longitude: -77.4360
        )
      end
    end
  end
end
