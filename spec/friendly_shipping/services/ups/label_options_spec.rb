# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups/label_options'

RSpec.describe FriendlyShipping::Services::Ups::LabelOptions do
  subject(:options) { described_class.new(shipping_method: double, shipper_number: double) }
  [
    :shipping_method,
    :shipper_number,
    :shipper,
    :customer_context,
    :validate_address,
    :negotiated_rates,
    :billing_options,
    :sold_to,
    :saturday_delivery,
    :label_format,
    :label_size,
    :carbon_neutral,
    :paperless_invoice,
    :reason_for_export,
    :invoice_date
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  describe 'delivery_confirmation_code' do
    subject { options.delivery_confirmation_code }

    it { is_expected.to be nil }

    context 'if delivery confirmation is set' do
      let(:options) { described_class.new(shipping_method: double, shipper_number: double, delivery_confirmation: :delivery_confirmation_signature_required) }

      it { is_expected.to eq 1 }
    end
  end

  describe 'terms_of_shipment_code' do
    subject { options.terms_of_shipment_code }

    it { is_expected.to be nil }

    context 'if delivery confirmation is set' do
      let(:options) { described_class.new(shipping_method: double, shipper_number: double, terms_of_shipment: :carriage_paid_to) }

      it { is_expected.to eq 'CPT' }
    end
  end

  describe 'return_service_code' do
    subject { options.return_service_code }

    it { is_expected.to be nil }

    context 'if delivery confirmation is set' do
      let(:options) { described_class.new(shipping_method: double, shipper_number: double, return_service: :ups_pack_collect_3_attemt_box_5) }

      it { is_expected.to eq 20 }
    end
  end

  describe '#options_for_package' do
    subject { options.options_for_package(double(package_id: 'my_package_id')) }

    it { is_expected.to be_a(FriendlyShipping::Services::Ups::LabelPackageOptions) }
  end
end
