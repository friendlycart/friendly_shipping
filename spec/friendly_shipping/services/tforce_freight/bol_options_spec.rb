# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::BOLOptions do
  subject(:options) do
    described_class.new(
      service_code: "308",
      pickup_at: Time.parse("2024-01-22 12:30:00"),
      pickup_time_window: Time.parse("2024-01-22 08:00:00")..Time.parse("2024-01-22 16:00:00"),
      density_eligible: true,
      preview_rate: true,
      time_in_transit: true,
      billing: :prepaid,
      pickup_instructions: "East Dock",
      handling_instructions: "Handle with care",
      delivery_instructions: "West Dock",
      pickup_options: %w[LIFO],
      delivery_options: %w[LIFD],
      document_options: document_options
    )
  end

  let(:document_options) do
    [
      FriendlyShipping::Services::TForceFreight::DocumentOptions.new(
        type: :tforce_bol
      )
    ]
  end

  it { is_expected.to be_a(FriendlyShipping::Services::TForceFreight::BOLOptions) }

  it "has the right attributes" do
    expect(options.service_code).to eq("308")
    expect(options.pickup_at).to eq(Time.parse("2024-01-22 12:30:00"))
    expect(options.pickup_time_window).to eq(Time.parse("2024-01-22 08:00:00")..Time.parse("2024-01-22 16:00:00"))
    expect(options.density_eligible).to be(true)
    expect(options.preview_rate).to be(true)
    expect(options.time_in_transit).to be(true)
    expect(options.billing_code).to eq("10")
    expect(options.pickup_instructions).to eq("East Dock")
    expect(options.handling_instructions).to eq("Handle with care")
    expect(options.delivery_instructions).to eq("West Dock")
    expect(options.pickup_options).to eq(%w[LIFO])
    expect(options.delivery_options).to eq(%w[LIFD])
    expect(options.document_options).to eq(document_options)
  end

  describe "#reference_numbers" do
    subject(:options) do
      described_class.new(
        reference_numbers: [
          { code: :bill_of_lading_number, value: "123" },
          { code: :consignee_reference, value: "456" }
        ]
      )
    end

    it "fills codes from lookup table" do
      expect(options.reference_numbers).to eq(
        [
          { code: "BL", value: "123" },
          { code: "CO", value: "456" }
        ]
      )
    end
  end

  describe "pickup option validation" do
    subject(:options) { described_class.new(pickup_options: %w[bogus invalid]) }

    it do
      expect { options }.to raise_error(ArgumentError, "Invalid pickup option(s): bogus, invalid")
    end
  end

  describe "delivery option validation" do
    subject(:options) { described_class.new(delivery_options: %w[bogus invalid]) }

    it do
      expect { options }.to raise_error(ArgumentError, "Invalid delivery option(s): bogus, invalid")
    end
  end
end
