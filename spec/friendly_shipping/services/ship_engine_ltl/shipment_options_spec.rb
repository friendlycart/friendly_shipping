# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngineLTL::ShipmentOptions do
  subject(:options) { described_class.new }

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::Services::ShipEngineLTL::PackageOptions }
    let(:required_attrs) { {} }
  end

  describe 'structure options' do
    subject(:options) { described_class.new(structure_options: structure_options) }

    let(:structure_1) { FactoryBot.build(:physical_structure, id: 'structure_1') }
    let(:structure_2) { FactoryBot.build(:physical_structure, id: 'structure_2') }
    let(:options_for_structure_1) { double(structure_id: 'structure_1') }
    let(:options_for_structure_2) { double(structure_id: 'structure_2') }
    let(:structure_options) do
      [
        options_for_structure_1,
        options_for_structure_2
      ]
    end

    it 'finds the right options for a structure' do
      expect(subject.options_for_structure(structure_1)).to eq(options_for_structure_1)
      expect(subject.options_for_structure(structure_2)).to eq(options_for_structure_2)
    end

    context 'if no structure options are given' do
      subject { described_class.new(structure_options: []) }

      it "returns an instance of the structure options class" do
        expect(subject.options_for_structure(structure_1)).to be_a(FriendlyShipping::Services::ShipEngineLTL::StructureOptions)
      end
    end
  end
end
