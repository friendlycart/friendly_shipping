# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip::MachinablePackage do
  subject { described_class.new(package) }
  let(:package) { Physical::Package.new(weight: weight, dimensions: dimensions) }

  describe "#machinable?" do
    let(:weight) { Measured::Weight(3, :ounces) }
    let(:dimensions) { [8, 4, 2].map { |e| Measured::Length(e, :inches) } }

    it { is_expected.to be_machinable }

    context "with oversize package" do
      let(:dimensions) { [30, 20, 20].map { |e| Measured::Length(e, :inches) } }

      it { is_expected.to_not be_machinable }
    end

    context "with only one dimension too large" do
      let(:dimensions) { [16, 16, 30].map { |e| Measured::Length(e, :inches) } }

      it { is_expected.not_to be_machinable }
    end

    context "with one dimension too small" do
      let(:dimensions) { [5, 3, 0.25].map { |e| Measured::Length(e, :inches) } }

      it { is_expected.to_not be_machinable }
    end

    context "with overweight package" do
      let(:weight) { Measured::Weight(50, :pounds) }

      it { is_expected.to_not be_machinable }
    end
  end
end
