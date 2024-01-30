# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::GenerateReferenceHash do
  let(:reference_numbers) do
    [
      { code: "BL", value: "1234" },
      { code: "CO", value: "5678" }
    ]
  end

  subject { described_class.call(reference_numbers: reference_numbers) }

  it "has all the right things" do
    is_expected.to eq(
      references: [
        {
          number: "1234",
          type: "BL"
        }, {
          number: "5678",
          type: "CO"
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
