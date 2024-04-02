# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip::RateEstimateOptions do
  subject(:options) { described_class.new(shipping_method: shipping_method) }

  let(:shipping_method) { FriendlyShipping::ShippingMethod.new }

  [
    :shipping_method,
    :processing_category,
    :rate_indicator,
    :destination_entry_facility_type,
    :price_type,
    :mailing_date
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::PackageOptions }
    let(:required_attrs) { { shipping_method: shipping_method } }
  end

  describe "#processing_category" do
    subject(:processing_category) { options.processing_category }

    it { is_expected.to eq("MACHINABLE") }
  end

  describe "#rate_indicator" do
    subject(:rate_indicator) { options.rate_indicator }

    it { is_expected.to eq("DR") }
  end

  describe "#destination_entry_facility_type" do
    subject(:destination_entry_facility_type) { options.destination_entry_facility_type }

    it { is_expected.to eq("NONE") }
  end

  describe "#price_type" do
    subject(:price_type) { options.price_type }

    it { is_expected.to eq("RETAIL") }
  end
end
