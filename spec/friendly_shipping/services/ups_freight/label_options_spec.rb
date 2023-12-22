# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/label_options'

RSpec.describe FriendlyShipping::Services::UpsFreight::LabelOptions do
  subject(:label_options) do
    described_class.new(
      shipper_number: 'my_shipper_number',
      billing_address: double,
      shipping_method: double,
      reference_numbers: reference_numbers
    )
  end

  let(:reference_numbers) { [] }

  it { is_expected.to be_a(FriendlyShipping::Services::UpsFreight::LabelOptions) }

  [
    :document_options,
    :email_options,
    :pickup_options,
    :delivery_options,
    :pickup_instructions,
    :delivery_instructions,
    :handling_instructions,
    :reference_numbers
  ].each do |option|
    it { is_expected.to respond_to(option) }
  end

  describe '#reference_numbers' do
    let(:reference_numbers) do
      [
        { code: :bill_of_lading_number, value: '123' },
        { code: :consignee_reference, value: '456' }
      ]
    end

    it 'fills codes from lookup table' do
      expect(subject.reference_numbers).to eq(
        [
          { code: '57', value: '123' },
          { code: 'CO', value: '456' }
        ]
      )
    end
  end

  describe 'package options' do
    let(:package) { double(package_id: nil) }

    subject { label_options.options_for_package(package) }

    it { is_expected.to be_a(FriendlyShipping::Services::UpsFreight::LabelPackageOptions) }
  end
end
