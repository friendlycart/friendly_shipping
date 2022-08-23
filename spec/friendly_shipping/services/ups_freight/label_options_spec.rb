# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/label_options'

RSpec.describe FriendlyShipping::Services::UpsFreight::LabelOptions do
  let(:reference_numbers) { [] }
  subject do
    described_class.new(
      shipper_number: 'my_shipper_number',
      billing_address: double,
      shipping_method: double,
      reference_numbers: reference_numbers
    )
  end

  it { is_expected.to be_a(FriendlyShipping::Services::UpsFreight::LabelOptions) }
  it { is_expected.to respond_to(:pickup_instructions) }
  it { is_expected.to respond_to(:delivery_instructions) }
  it { is_expected.to respond_to(:handling_instructions) }

  describe "#reference_numbers" do
    let(:reference_numbers) do
      [
        { code: :bill_of_lading_number, value: "123" },
        { code: :consignee_reference, value: "456" }
      ]
    end

    it "fills codes from lookup table" do
      expect(subject.reference_numbers).to eq(
        [
          { code: "57", value: "123" },
          { code: "CO", value: "456" }
        ]
      )
    end
  end
end
