# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::ShipmentInformation do
  subject do
    described_class.new(
      pro_number: "123",
      pickup_request_number: "456"
    )
  end

  it { is_expected.to respond_to(:documents) }
  it { is_expected.to respond_to(:pro_number) }
  it { is_expected.to respond_to(:pickup_request_number) }

  describe "#valid?" do
    it { is_expected.to be_valid }

    context "when values are missing" do
      subject do
        described_class.new(
          pro_number: nil,
          pickup_request_number: nil
        )
      end

      it { is_expected.not_to be_valid }
    end
  end
end
