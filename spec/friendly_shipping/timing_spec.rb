# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/timing'

RSpec.describe FriendlyShipping::Timing do
  let(:shipping_method) { FriendlyShipping::ShippingMethod.new(name: 'Acme Shipping', service_code: 'acme-08') }

  subject { described_class.new(shipping_method: shipping_method, pickup: Time.now, delivery: Time.now + 2.days) }

  it 'has pickup and arrival time objects' do
    expect(subject.pickup).to be_a(Time)
    expect(subject.delivery).to be_a(Time)
    expect(subject.properties).to be_a(Hash)
  end
end
