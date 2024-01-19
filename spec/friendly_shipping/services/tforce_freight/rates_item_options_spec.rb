# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/tforce_freight/rates_item_options'

RSpec.describe FriendlyShipping::Services::TForceFreight::RatesItemOptions do
  subject(:rates_item_options) do
    described_class.new(
      item_id: nil,
      packaging: :carton,
      freight_class: "92.5",
      nmfc_primary_code: "16030",
      nmfc_sub_code: "01",
      hazardous: true
    )
  end

  it "has the right attributes" do
    expect(rates_item_options.freight_class).to eq("92.5")
    expect(rates_item_options.nmfc_primary_code).to eq("16030")
    expect(rates_item_options.nmfc_sub_code).to eq("01")
    expect(rates_item_options.packaging_code).to eq("CTN")
    expect(rates_item_options.packaging_description).to eq("Carton")
    expect(rates_item_options.hazardous).to be(true)
  end

  context "with loose packaging" do
    subject(:rates_item_options) do
      described_class.new(
        item_id: nil,
        packaging: :loose
      )
    end

    it "has the right attributes" do
      expect(rates_item_options.packaging_code).to eq("LOO")
      expect(rates_item_options.packaging_description).to eq("Loose")
    end
  end
end
