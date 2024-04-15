# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip::RateEstimateOptions do
  subject(:options) { described_class.new(shipping_method: shipping_method) }

  let(:shipping_method) { FriendlyShipping::ShippingMethod.new }

  [
    :shipping_method,
    :destination_entry_facility_type,
    :mailing_date
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::PackageOptions }
    let(:required_attrs) { { shipping_method: shipping_method } }
  end

  describe "#destination_entry_facility_type" do
    subject(:destination_entry_facility_type) { options.destination_entry_facility_type }

    it { is_expected.to eq("NONE") }
  end

  describe "#mailing_date" do
    subject(:mailing_date) { options.mailing_date }

    it { is_expected.to eq(Date.today) }
  end
end
