# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsJson::RatesItemOptions do
  subject(:rates_item_options) { described_class.new(item_id: nil, commodity_code: "3303.00.0010", country_of_origin: "US") }

  it "has the right attributes" do
    expect(rates_item_options.commodity_code).to eq("3303.00.0010")
    expect(rates_item_options.country_of_origin).to eq("US")
  end
end
