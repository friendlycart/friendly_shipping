# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight'

RSpec.describe FriendlyShipping::Services::UpsFreight do
  subject(:service) { described_class.new(login: ENV['UPS_LOGIN'], password: ENV['UPS_PASSWORD'], key: ENV['UPS_KEY']) }

  describe 'carriers' do
    subject { service.carriers.value! }

    it 'has only one carrier with four shipping methods' do
      expect(subject.length).to eq(1)
      expect(subject.first.shipping_methods.map(&:service_code)).to contain_exactly(
        '308', '309', '334', '349'
      )
      expect(subject.first.shipping_methods.map(&:name)).to contain_exactly(
        'UPS Freight LTL',
        'UPS Freight LTL - Guaranteed',
        'UPS Freight LTL - Guaranteed A.M.',
        'UPS Standard LTL',
      )
    end
  end
end
