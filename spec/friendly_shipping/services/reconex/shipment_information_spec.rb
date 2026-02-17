# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Reconex::ShipmentInformation do
  subject do
    described_class.new(
      load_id: "3310514",
      pro_number: "PRO123",
      billing_id: "2223606199",
      custom_id: "0001181699",
      po_number: "13504399",
      customer_billing: ",2223441299"
    )
  end

  it { is_expected.to respond_to(:load_id) }
  it { is_expected.to respond_to(:pro_number) }
  it { is_expected.to respond_to(:billing_id) }
  it { is_expected.to respond_to(:custom_id) }
  it { is_expected.to respond_to(:po_number) }
  it { is_expected.to respond_to(:customer_billing) }

  describe "#valid?" do
    it { is_expected.to be_valid }

    context "when load_id is nil" do
      subject { described_class.new(load_id: nil) }

      it { is_expected.not_to be_valid }
    end

    context "when load_id is empty" do
      subject { described_class.new(load_id: "") }

      it { is_expected.not_to be_valid }
    end
  end
end
