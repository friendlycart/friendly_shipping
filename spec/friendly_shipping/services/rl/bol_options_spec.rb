# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::BOLOptions do
  subject(:options) do
    described_class.new(
      pickup_time_window: 1.hour.ago..1.hour.from_now,
      additional_service_codes: additional_service_codes
    )
  end

  let(:additional_service_codes) { %w[OriginLiftgate] }

  it { is_expected.to respond_to(:pickup_time_window) }
  it { is_expected.to respond_to(:declared_value) }
  it { is_expected.to respond_to(:additional_service_codes) }
  it { is_expected.to respond_to(:generate_universal_pro) }

  describe "validate additional service codes" do
    context "with invalid additional service code" do
      let(:additional_service_codes) { %w[InsidePickup bogus] }

      it "raises exception" do
        expect { options }.to raise_exception(ArgumentError, "Invalid additional service code(s): bogus")
      end
    end
  end
end
