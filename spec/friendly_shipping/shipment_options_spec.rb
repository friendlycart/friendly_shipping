# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::ShipmentOptions do
  describe 'Package options' do
    let(:package_1) { FactoryBot.build(:physical_package, id: 'package_1') }
    let(:package_2) { FactoryBot.build(:physical_package, id: 'package_2') }
    let(:options_for_package_1) { double(package_id: 'package_1') }
    let(:options_for_package_2) { double(package_id: 'package_2') }
    let(:package_options) do
      [
        options_for_package_1,
        options_for_package_2
      ]
    end

    subject { described_class.new(package_options: package_options) }

    it 'finds the right options for a package' do
      expect(subject.options_for_package(package_1)).to eq(options_for_package_1)
      expect(subject.options_for_package(package_2)).to eq(options_for_package_2)
    end

    context 'if no package options are given' do
      subject { described_class.new(package_options: []) }

      it "returns an instance of the package options class" do
        expect(subject.options_for_package(package_1)).to be_a(FriendlyShipping::PackageOptions)
      end
    end
  end
end
