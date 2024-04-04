# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsJson::GeneratePackageHash do
  subject(:call) {
    described_class.call(
      package: package
    )
  }

  let(:item1) { Physical::Item.new(cost: Money.new(495, 'USD')) }
  let(:item2) { Physical::Item.new(cost: Money.new(1195, 'USD')) }
  let(:package) {
    Physical::Package.new(container: Physical::Box.new(weight: Measured::Weight.new(5.025, :pounds)),
                          items: [item1, item2])
  }

  it 'returns a hash' do
    expect(subject[:Packaging][:Code]).to eq("02")
    expect(subject[:PackageWeight][:UnitOfMeasurement][:Code]).to eq("LBS")
    expect(subject[:PackageWeight][:Weight]).to eq("5.03")
    expect(subject[:Dimensions]).to be_nil
    expect(subject[:ReferenceNumber]).to be_nil
  end

  context "when rates are being requested" do
    subject(:call) {
      described_class.call(
        package: package,
        package_flavor: "rates"
      )
    }

    it 'returns a hash with a different top level key name' do
      expect(subject[:PackagingType][:Code]).to eq("02")
    end
  end

  context 'if the package has dimensions' do
    let(:dimensions) do
      [
        Measured::Length.new(30, :centimeters),
        Measured::Length.new(20, :centimeters),
        Measured::Length.new(10, :centimeters),
      ]
    end
    let(:package) do
      Physical::Package.new(
        container: Physical::Box.new(
          weight: Measured::Weight.new(5, :pounds),
          dimensions: dimensions
        )
      )
    end

    it 'adds dimensions to the package' do
      expect(subject[:Dimensions][:UnitOfMeasurement][:Code]).to eq('IN')
      expect(subject[:Dimensions][:Length]).to eq('11.81')
      expect(subject[:Dimensions][:Width]).to eq('7.87')
      expect(subject[:Dimensions][:Height]).to eq('3.94')
    end

    context 'if a dimension is zero' do
      let(:dimensions) { [0, 1, 0].map { |n| Measured::Length(n, :cm) } }

      it 'does not add dimensions' do
        expect(subject.key?(:Dimensions)).to be false
      end
    end

    context 'if serializer is told to not transmit dimensions' do
      let(:package) do
        Physical::Package.new(
          container: Physical::Box.new(
            weight: Measured::Weight.new(5, :pounds),
            dimensions: dimensions
          )
        )
      end

      subject(:call) { described_class.call(package: package, transmit_dimensions: false) }

      it 'does not add dimensions' do
        expect(subject.key?(:Dimensions)).to be false
      end
    end
  end

  context 'if the package has reference numbers' do
    subject(:call) {
      described_class.call(
        package: package,
        reference_numbers: { ix: '334455' }
      )
    }

    it 'adds reference numbers to the package' do
      expect(subject[:ReferenceNumber]).to be_a(Array)
      expect(subject[:ReferenceNumber].first[:Code]).to eq('ix')
      expect(subject[:ReferenceNumber].first[:Value]).to eq('334455')
    end
  end

  context 'if the package has shipper_release set to true' do
    subject(:call) {
      described_class.call(
        package: package,
        shipper_release: true
      )
    }

    it 'adds the shipper release indicator to the package service options' do
      expect(subject[:PackageServiceOptions][:ShipperReleaseIndicator]).to be true
    end
  end

  context 'with delivery confirmation code' do
    subject(:call) {
      described_class.call(
        package: package,
        delivery_confirmation_code: "5678"
      )
    }

    it 'adds the delivery confirmation to the package service options' do
      expect(subject[:PackageServiceOptions][:DeliveryConfirmation][:DCISType]).to eq("5678")
    end
  end

  context 'if the package has declared_value set to true' do
    subject(:call) {
      described_class.call(
        package: package,
        package_flavor: "rates",
        declared_value: true
      )
    }

    it 'adds declared value to the package service options' do
      expect(subject[:PackageServiceOptions][:DeclaredValue][:CurrencyCode]).to eq("USD")
      expect(subject[:PackageServiceOptions][:DeclaredValue][:MonetaryValue]).to eq("16.90")
    end
  end
end
