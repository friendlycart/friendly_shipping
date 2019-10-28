# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/package_options'

RSpec.describe FriendlyShipping::PackageOptions do
  subject { described_class.new(package_id: 'my_package_id') }

  it { is_expected.to respond_to(:package_id) }

  describe 'Item options' do
    let(:item_1) { FactoryBot.build(:physical_item, id: 'item_1') }
    let(:item_2) { FactoryBot.build(:physical_item, id: 'item_2') }
    let(:options_for_item_1) { double(item_id: 'item_1') }
    let(:options_for_item_2) { double(item_id: 'item_2') }
    let(:item_options) do
      [
        options_for_item_1,
        options_for_item_2
      ]
    end

    subject { described_class.new(package_id: 'my_package_id', item_options: item_options) }

    it 'finds the right options for a item' do
      expect(subject.options_for_item(item_1)).to eq(options_for_item_1)
      expect(subject.options_for_item(item_2)).to eq(options_for_item_2)
    end
  end
end
