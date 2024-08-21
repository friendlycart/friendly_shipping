# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::ParseRateQuoteResponse do
  subject { described_class.call(request: request, response: response) }

  let(:response) { double(body: response_body) }
  let(:request) { double(debug: false) }

  context "with successful response" do
    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "rl", "rate_quote", "success.json")) }
    let(:api_result) { subject.value! }
    let(:rate) { api_result.data.first }

    it "returns an Array of rates" do
      expect(subject).to be_success
      expect(api_result.data).to be_a Array
      expect(rate).to be_a FriendlyShipping::Rate
    end

    it "contains correct data" do
      expect(rate.amounts).to eq(total: Money.new(43_671, "USD"))
      expect(rate.shipping_method.name).to eq("Standard Service")
      expect(rate.shipping_method.service_code).to eq("STD")
      expect(rate.warnings).to be_empty
      expect(rate.errors).to be_empty
      expect(rate.data).to eq(
        cost_breakdown: [
          { "Amount" => "$11.25", "Description" => "Class: 92.5", "Rate" => "$1,124.72", "Weight" => "1" },
          { "Amount" => "$11.25", "Description" => "Class: 92.5", "Rate" => "$1,124.72", "Weight" => "1" },
          { "Amount" => "$11.25", "Description" => "Class: 92.5", "Rate" => "$1,124.72", "Weight" => "1" },
          { "Amount" => "$11.25", "Description" => "Class: 92.5", "Rate" => "$1,124.72", "Weight" => "1" },
          { "Amount" => "$1,690.72", "Description" => "Minimum Charge", "Type" => "MINIMUM" },
          { "Amount" => "$1,487.83", "Description" => "R+L Discount Saves This Much", "Rate" => "88%", "Type" => "DISCNT" },
          { "Amount" => "$202.89", "Description" => "Discounted Freight Charge", "Type" => "DISCNF" },
          { "Amount" => "$71.62", "Description" => "Fuel Surcharge", "Rate" => "35.3%", "Type" => "FUEL" },
          { "Amount" => "$110.90", "Description" => "Manhattan Arbitrary Charge", "Type" => "ARBMH" },
          { "Amount" => "$51.30", "Description" => "Hazmat Fee", "Rate" => "$51.30", "Type" => "HAZM" },
          { "Amount" => "$436.71", "Description" => "Net Charge", "Type" => "NET" }
        ]
      )
    end

    it "adds non-standard service level charges to cost breakdowns" do
      non_standard_rates = api_result.data.reject { |rate| rate.shipping_method.service_code == "STD" }
      expect(non_standard_rates.size).to eq(1)
      expect(non_standard_rates.first.data[:cost_breakdown]).to eq(
        [
          { "Amount" => "$11.25", "Description" => "Class: 92.5", "Rate" => "$1,124.72", "Weight" => "1" },
          { "Amount" => "$11.25", "Description" => "Class: 92.5", "Rate" => "$1,124.72", "Weight" => "1" },
          { "Amount" => "$11.25", "Description" => "Class: 92.5", "Rate" => "$1,124.72", "Weight" => "1" },
          { "Amount" => "$11.25", "Description" => "Class: 92.5", "Rate" => "$1,124.72", "Weight" => "1" },
          { "Amount" => "$1,690.72", "Description" => "Minimum Charge", "Type" => "MINIMUM" },
          { "Amount" => "$1,487.83", "Description" => "R+L Discount Saves This Much", "Rate" => "88%", "Type" => "DISCNT" },
          { "Amount" => "$202.89", "Description" => "Discounted Freight Charge", "Type" => "DISCNF" },
          { "Amount" => "$71.62", "Description" => "Fuel Surcharge", "Rate" => "35.3%", "Type" => "FUEL" },
          { "Amount" => "$110.90", "Description" => "Manhattan Arbitrary Charge", "Type" => "ARBMH" },
          { "Amount" => "$51.30", "Description" => "Hazmat Fee", "Rate" => "$51.30", "Type" => "HAZM" },
          { "Amount" => "$436.71", "Description" => "Net Charge", "Type" => "NET" },
          { "Amount" => "$51.30", "Description" => "Guaranteed Service", "Type" => "GSDS" }
        ]
      )
    end
  end

  context "with unsuccessful response" do
    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "rl", "rate_quote", "failure.json")) }
    let(:api_result) { subject.failure }

    it "returns error message" do
      expect(subject).to be_failure
      expect(api_result.data).to eq(["At least one Item is required"])
    end
  end
end
