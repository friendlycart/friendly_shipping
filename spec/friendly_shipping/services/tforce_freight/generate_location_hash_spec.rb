# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/tforce_freight/generate_location_hash'

RSpec.describe FriendlyShipping::Services::TForceFreight::GenerateLocationHash do
  describe ".call" do
    subject(:call) { described_class.call(location: location) }

    let(:location) do
      Physical::Location.new(
        city: "Richmond",
        zip: "23224",
        region: "VA",
        country: "US"
      )
    end

    it do
      is_expected.to eq(
        address: {
          city: "Richmond",
          stateProvinceCode: "VA",
          postalCode: "23224",
          country: "US"
        }
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

      it do
        is_expected.to eq(
          address: {
            stateProvinceCode: "VA",
            postalCode: "23224",
            country: "US"
          }
        )
      end
    end
  end
end
