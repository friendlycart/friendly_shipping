# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/rates_package_options'

RSpec.describe FriendlyShipping::Services::UpsFreight::RatesPackageOptions do
  subject(:rates_package_options) { described_class.new(package_id: nil) }

  it 'has the right attributes' do
    expect(subject.handling_unit_code).to eq('PLT')
    expect(subject.handling_unit_description).to eq('Pallet')
    expect(subject.handling_unit_tag).to eq('HandlingUnitOne')
  end

  context 'with loose packaging' do
    subject { described_class.new(package_id: nil, handling_unit: :loose) }

    it 'has the right attributes' do
      expect(subject.handling_unit_code).to eq('LOO')
      expect(subject.handling_unit_description).to eq('Loose')
      expect(subject.handling_unit_tag).to eq('HandlingUnitTwo')
    end
  end

  describe 'item options' do
    let(:item) { double(item_id: nil) }

    subject { rates_package_options.options_for_item(item) }

    it { is_expected.to be_a(FriendlyShipping::Services::UpsFreight::RatesItemOptions) }
  end
end
