# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::PickupOptions do
  subject(:options) do
    described_class.new(
      pickup_at: Time.parse("2023-05-18 12:30:00"),
      pickup_time_window: Time.parse("2023-05-18 08:00:00")..Time.parse("2023-05-18 16:00:00"),
      service_options: %w[INPU LIFO],
      pickup_instructions: "East Dock",
      handling_instructions: "Handle with care",
      delivery_instructions: "West Dock"
    )
  end

  let(:shipping_method) { FriendlyShipping::ShippingMethod.new }

  it { is_expected.to be_a(FriendlyShipping::ShipmentOptions) }

  [
    :pickup_at,
    :pickup_time_window,
    :service_options,
    :pickup_instructions,
    :handling_instructions,
    :delivery_instructions
  ].each do |option|
    it { is_expected.to respond_to(option) }
  end

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::Services::TForceFreight::RatesPackageOptions }
    let(:required_attrs) { {} }
  end

  it "has the right attributes" do
    expect(options.pickup_at).to eq(Time.parse("2023-05-18 12:30:00"))
    expect(options.pickup_time_window).to eq(Time.parse("2023-05-18 08:00:00")..Time.parse("2023-05-18 16:00:00"),)
    expect(options.service_options).to eq(%w[INPU LIFO])
    expect(options.pickup_instructions).to eq("East Dock")
    expect(options.handling_instructions).to eq("Handle with care")
    expect(options.delivery_instructions).to eq("West Dock")
  end

  describe "package options" do
    subject(:package_options) { options.options_for_package(package) }

    let(:package) { double(package_id: nil) }

    it { is_expected.to be_a(FriendlyShipping::Services::TForceFreight::RatesPackageOptions) }
  end

  describe "service option validation" do
    subject(:options) do
      described_class.new(
        service_options: %w[bogus invalid]
      )
    end

    it do
      expect { options }.to raise_error(ArgumentError, "Invalid service option(s): bogus, invalid")
    end
  end
end
