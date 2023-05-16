# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::SerializePackageNode do
  subject(:context) do
    Nokogiri::XML::Builder.new do |xml|
      described_class.call(xml: xml, package: package)
    end.doc
  end

  let(:package) do
    Physical::Package.new(
      container: Physical::Box.new(
        weight: Measured::Weight.new(5.025, :pounds)
      ),
      items: Array.new(2) {
        Physical::Item.new(cost: Money.new(495, 'USD'))
      }
    )
  end

  it 'adds a package to the context' do
    expect(subject.at_xpath('//Package')).to be_present
    expect(subject.at_xpath('//Package/PackagingType/Code').text).to eq('02')
    expect(subject.at_xpath('//Package/PackageWeight/UnitOfMeasurement/Code').text).to eq('LBS')
    expect(subject.at_xpath('//Package/PackageWeight/Weight').text).to eq('6')
    expect(subject.at_xpath('//Package/Dimensions')).not_to be_present
    expect(subject.at_xpath('//Package/ReferenceNumber')).not_to be_present
  end

  context 'if package has dimensions' do
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
      expect(subject.at_xpath('//Package/Dimensions')).to be_present
      expect(subject.at_xpath('//Package/Dimensions/UnitOfMeasurement/Code').text).to eq('IN')
      expect(subject.at_xpath('//Package/Dimensions/Length').text).to eq('11.811')
      expect(subject.at_xpath('//Package/Dimensions/Width').text).to eq('7.874')
      expect(subject.at_xpath('//Package/Dimensions/Height').text).to eq('3.937')
    end

    context 'if a dimension is zero' do
      let(:dimensions) { [0, 1, 0].map { |n| Measured::Length(n, :cm) } }

      it 'does not add dimensions' do
        expect(subject.at_xpath('//Package/Dimensions')).not_to be_present
      end
    end

    context 'if serializer is told to not transmit dimensions' do
      subject(:context) do
        Nokogiri::XML::Builder.new do |xml|
          described_class.call(xml: xml, package: package, transmit_dimensions: false)
        end.doc
      end

      it 'does not add dimensions' do
        expect(subject.at_xpath('//Package/Dimensions')).not_to be_present
      end
    end
  end

  context 'if package has reference numbers' do
    subject(:context) do
      Nokogiri::XML::Builder.new do |xml|
        described_class.call(xml: xml, package: package, reference_numbers: { ix: '334455' })
      end.doc
    end

    it 'adds reference numbers to the package' do
      expect(subject.at_xpath('//Package/ReferenceNumber')).to be_present
      expect(subject.at_xpath('//Package/ReferenceNumber/Code').text).to eq('ix')
      expect(subject.at_xpath('//Package/ReferenceNumber/Value').text).to eq('334455')
    end
  end

  context 'if package has shipper_release set to true' do
    subject(:context) do
      Nokogiri::XML::Builder.new do |xml|
        described_class.call(xml: xml, package: package, shipper_release: true)
      end.doc
    end

    it 'adds the shipper release indicator to the package service options' do
      expect(subject.at_xpath('//Package/PackageServiceOptions/ShipperReleaseIndicator')).to be_present
    end
  end

  context 'with delivery confirmation code' do
    subject(:context) do
      Nokogiri::XML::Builder.new do |xml|
        described_class.call(xml: xml, package: package, delivery_confirmation_code: '5678')
      end.doc
    end

    it 'adds the delivery confirmation to the package service options' do
      expect(subject.at_xpath('//Package//PackageServiceOptions/DeliveryConfirmation')).to be_present
      expect(subject.at_xpath('//Package//PackageServiceOptions/DeliveryConfirmation/DCISType').text).to eq('5678')
    end
  end

  context 'if package has declared_value set to true' do
    subject(:context) do
      Nokogiri::XML::Builder.new do |xml|
        described_class.call(xml: xml, package: package, declared_value: true)
      end.doc
    end

    it 'adds declared value to the package service options' do
      expect(subject.at_xpath('//Package//PackageServiceOptions/DeclaredValue')).to be_present
      expect(subject.at_xpath('//Package//PackageServiceOptions/DeclaredValue/CurrencyCode').text).to eq('USD')
      expect(subject.at_xpath('//Package//PackageServiceOptions/DeclaredValue/MonetaryValue').text).to eq('9.90')
    end
  end
end
