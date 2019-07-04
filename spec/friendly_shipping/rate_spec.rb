# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Rate do
  subject do
    described_class.new(
      shipping_method: FriendlyShipping::ShippingMethod.new,
      amounts: { shipping: Money.new(1000, 'USD') }
    )
  end
  it { is_expected.to respond_to(:shipping_method) }
  it { is_expected.to respond_to(:remote_service_id) }
  it { is_expected.to respond_to(:delivery_date) }
  it { is_expected.to respond_to(:warnings) }
  it { is_expected.to respond_to(:errors) }
  it { is_expected.to respond_to(:data) }

  describe '#total_amount' do
    subject do
      described_class.new(
        shipping_method: FriendlyShipping::ShippingMethod.new,
        amounts: amounts
      ).total_amount
    end

    context 'if no amounts given' do
      let(:amounts) { [] }

      it 'raises an exception' do
        expect { subject }.to raise_exception(FriendlyShipping::Rate::NoAmountsGiven)
      end
    end

    context 'if amounts given' do
      let(:amounts) { { shipping: Money.new(1200, "USD"), other: Money.new(300, "USD") } }

      it { is_expected.to eq(Money.new(1500, "USD")) }
    end
  end
end
