# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/tforce_freight/rates_options'

RSpec.describe FriendlyShipping::Services::TForceFreight::RatesOptions do
  subject(:rates_options) do
    described_class.new(
      pickup_date: Date.parse("2023-05-18"),
      billing_address: billing_location,
      shipping_method: shipping_method,
      billing: :prepaid,
      type: :l,
      density_eligible: true,
      accessorial_rate: true,
      time_in_transit: false,
      quote_number: true,
      pickup_options: %w[LIFO],
      delivery_options: %w[LIFD],
      customer_context: "order-12345"
    )
  end

  let(:billing_location) do
    Physical::Location.new(
      city: "Durham",
      zip: "27703",
      region: "NC",
      country: "US"
    )
  end

  let(:shipping_method) { FriendlyShipping::ShippingMethod.new }

  it { is_expected.to be_a(FriendlyShipping::ShipmentOptions) }

  [
    :pickup_date,
    :billing_address,
    :billing_code,
    :shipping_method,
    :type_code,
    :density_eligible,
    :accessorial_rate,
    :time_in_transit,
    :quote_number,
    :pickup_options,
    :delivery_options,
    :customer_context,
    :commodity_information_generator
  ].each do |option|
    it { is_expected.to respond_to(option) }
  end

  it "has the right attributes" do
    expect(rates_options.pickup_date).to eq(Date.parse("2023-05-18"))
    expect(rates_options.billing_address).to eq(billing_location)
    expect(rates_options.billing_code).to eq("10")
    expect(rates_options.shipping_method).to eq(shipping_method)
    expect(rates_options.type_code).to eq("L")
    expect(rates_options.density_eligible).to be(true)
    expect(rates_options.accessorial_rate).to be(true)
    expect(rates_options.time_in_transit).to be(false)
    expect(rates_options.quote_number).to be(true)
    expect(rates_options.pickup_options).to eq(%w[LIFO])
    expect(rates_options.delivery_options).to eq(%w[LIFD])
    expect(rates_options.customer_context).to eq("order-12345")
    expect(rates_options.commodity_information_generator).
      to eq(FriendlyShipping::Services::TForceFreight::GenerateCommodityInformation)
  end

  describe "package options" do
    subject(:package_options) { rates_options.options_for_package(package) }

    let(:package) { double(package_id: nil) }

    it { is_expected.to be_a(FriendlyShipping::Services::TForceFreight::RatesPackageOptions) }
  end

  describe "pickup option validation" do
    subject(:rates_options) do
      described_class.new(
        billing_address: billing_location,
        shipping_method: shipping_method,
        pickup_options: %w[bogus invalid]
      )
    end

    it do
      expect { rates_options }.to raise_error(ArgumentError, "Invalid pickup option(s): bogus, invalid")
    end
  end

  describe "delivery option validation" do
    subject(:rates_options) do
      described_class.new(
        billing_address: billing_location,
        shipping_method: shipping_method,
        delivery_options: %w[bogus invalid]
      )
    end

    it do
      expect { rates_options }.to raise_error(ArgumentError, "Invalid delivery option(s): bogus, invalid")
    end
  end
end
