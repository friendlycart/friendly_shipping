# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::SHIPPING_METHODS do
  subject(:shipping_methods) { described_class }

  it { expect(shipping_methods.size).to eq(4) }
  it { expect(shipping_methods).to all(be_a(FriendlyShipping::ShippingMethod)) }
end
