# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups/label_item_options'

RSpec.describe FriendlyShipping::Services::Ups::LabelItemOptions do
  subject { described_class.new(item_id: nil) }

  [
    :item_id,
    :commodity_code,
    :country_of_origin
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  describe '#product_unit_of_measure_code' do
    it 'returns product unit of measure code' do
      expect(subject.product_unit_of_measure_code).to eq('NMB')
    end
  end
end
