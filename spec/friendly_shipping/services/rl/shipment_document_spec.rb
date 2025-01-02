# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::ShipmentDocument do
  subject(:shipment_document) do
    described_class.new(
      format: :pdf,
      document_type: :bol,
      binary: "aGVsbG8gd29ybGQ="
    )
  end

  it { is_expected.to respond_to(:format) }
  it { is_expected.to respond_to(:document_type) }
  it { is_expected.to respond_to(:binary) }

  describe "#valid?" do
    it { is_expected.to be_valid }

    context "when values are missing" do
      subject do
        described_class.new(
          format: nil,
          document_type: nil,
          binary: nil
        )
      end

      it { is_expected.not_to be_valid }
    end
  end
end
