# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/rl/shipping_document'

RSpec.describe FriendlyShipping::Services::RL::ShippingDocument do
  subject(:bol_document) do
    described_class.new(
      binary: "aGVsbG8gd29ybGQ="
    )
  end

  it { is_expected.to respond_to(:format) }
  it { is_expected.to respond_to(:binary) }

  describe "#valid?" do
    it { is_expected.to be_valid }

    context "when values are missing" do
      subject do
        described_class.new(
          format: nil,
          binary: nil
        )
      end

      it { is_expected.not_to be_valid }
    end
  end

  describe "#decoded_binary" do
    subject { bol_document.decoded_binary }

    it { is_expected.to eq("hello world") }
  end
end
