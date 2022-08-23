# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/generate_reference_hash'

RSpec.describe FriendlyShipping::Services::UpsFreight::GenerateReferenceHash do
  let(:reference_numbers) do
    [
      { code: "57", value: "1234" },
      { code: "CO", value: "5678" }
    ]
  end

  subject { described_class.call(reference_numbers: reference_numbers) }

  it "has all the right things" do
    is_expected.to eq(
      Reference: [
        {
          Number: {
            Code: "57",
            Value: "1234"
          }
        }, {
          Number: {
            Code: "CO",
            Value: "5678"
          }
        }
      ]
    )
  end

  context "with nil reference numbers" do
    let(:reference_numbers) { nil }
    it { is_expected.to eq({}) }
  end

  context "with empty reference numbers" do
    let(:reference_numbers) { [] }
    it { is_expected.to eq({}) }
  end
end
