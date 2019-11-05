# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/rates_item_options'

RSpec.describe FriendlyShipping::Services::UpsFreight::RatesItemOptions do
  subject(:rates_item_options) { described_class.new(item_id: nil) }

  it 'has the right attributes' do
    expect(subject.freight_class).to be nil
    expect(subject.nmfc_code).to be nil
    expect(subject.packaging_code).to eq('CTN')
    expect(subject.packaging_description).to eq('Carton')
  end

  context 'with loose packaging' do
    subject { described_class.new(item_id: nil, packaging: :loose) }

    it 'has the right attributes' do
      expect(subject.packaging_code).to eq('LOO')
      expect(subject.packaging_description).to eq('Loose')
    end
  end
end
