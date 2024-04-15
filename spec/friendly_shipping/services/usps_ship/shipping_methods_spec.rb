# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip::SHIPPING_METHODS do
  subject(:shipping_methods) { described_class }

  it { expect(shipping_methods.size).to eq(20) }
  it { expect(shipping_methods).to all(be_a(FriendlyShipping::ShippingMethod)) }

  it do
    described_class.each do |shipping_method|
      expect(shipping_method.name).to be_present
      expect(shipping_method.service_code).to be_present
      expect(shipping_method.origin_countries).not_to be_empty
      expect(shipping_method.international? || shipping_method.domestic?).to be true
    end
  end
end
