# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::RatesPackageOptions do
  subject(:options) { described_class.new(package_id: "package") }

  it 'has the right attributes' do
    expect(subject.handling_unit_code).to eq('PLT')
    expect(subject.handling_unit_description).to eq('Pallet')
    expect(subject.handling_unit_tag).to eq('HandlingUnitOne')
  end

  it_behaves_like "overrideable item options class" do
    let(:default_class) { FriendlyShipping::Services::UpsFreight::RatesItemOptions }
  end

  context 'with loose packaging' do
    subject { described_class.new(package_id: nil, handling_unit: :loose) }

    it 'has the right attributes' do
      expect(subject.handling_unit_code).to eq('LOO')
      expect(subject.handling_unit_description).to eq('Loose')
      expect(subject.handling_unit_tag).to eq('HandlingUnitTwo')
    end
  end
end
