# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/usps/rate_estimate_options'

RSpec.describe FriendlyShipping::Services::Usps::SerializeRateRequest do
  let(:dimensions) { [10, 21.321539, 24].map { |e| Measured::Length(e, :cm) } }
  let(:weight) { Measured::Weight.new(14.025, :ounces) }
  let(:properties) { {} }
  let(:container) { FactoryBot.build(:physical_box, dimensions: dimensions, weight: weight) }
  let(:package) { FactoryBot.build(:physical_package, container: container, items: [], void_fill_density: Measured::Density(0, :g_ml)) }
  let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package]) }
  let(:options) { FriendlyShipping::Services::Usps::RateEstimateOptions.new(package_options: [package_options]) }
  let(:package_options) { FriendlyShipping::Services::Usps::RateEstimatePackageOptions.new(package_id: package.id) }
  subject(:parser) { described_class.call(shipment: shipment, login: 'fake', options: options) }

  let(:node) { Nokogiri::XML(subject).xpath('//RateV4Request/Package') }

  it 'serializes the request' do
    expect(node.at_xpath('Service').text).to eq('ALL')
    expect(node.at_xpath('Container').text).to eq('VARIABLE')
    expect(node.at_xpath('Size').text).to eq('REGULAR')
    expect(node.at_xpath('Width').text).to eq('8.39')
    expect(node.at_xpath('Length').text).to eq('3.94')
    expect(node.at_xpath('Height').text).to eq('9.45')
    expect(node.at_xpath('Girth').text).to eq('24.66')
    expect(node.at_xpath('Pounds').text).to eq('0')
    expect(node.at_xpath('Ounces').text).to eq('15')
    expect(node.at_xpath('Machinable').text).to eq('FALSE')
  end

  context 'with regional rate box name' do
    let(:package_options) do
      FriendlyShipping::Services::Usps::RateEstimatePackageOptions.new(
        package_id: package.id,
        box_name: :regional_rate_box_a
      )
    end

    it 'uses correct container' do
      expect(node.at_xpath('Container').text).to eq('REGIONALRATEBOXA')
      expect(node.at_xpath('Width')).to be nil
      expect(node.at_xpath('Length')).to be nil
      expect(node.at_xpath('Height')).to be nil
      expect(node.at_xpath('Girth')).to be nil
    end
  end

  context 'with large flat rate box name' do
    let(:package_options) do
      FriendlyShipping::Services::Usps::RateEstimatePackageOptions.new(
        package_id: package.id,
        box_name: :large_flat_rate_box
      )
    end

    it 'uses correct container' do
      expect(node.at_xpath('Container').text).to eq('LG FLAT RATE BOX')
    end
  end

  context 'with package weight that ceils to exactly 16 oz' do
    let(:weight) { Measured::Weight(15.6, :ounces) }

    it 'returns 15.999 oz' do
      expect(node.at_xpath('Ounces').text).to eq('15.999')
    end
  end

  context 'with priority shipping method' do
    let(:shipping_method) do
      FriendlyShipping::Services::Usps::SHIPPING_METHODS.detect do |shipping_method|
        shipping_method.name == 'Priority'
      end
    end
    let(:package_options) do
      FriendlyShipping::Services::Usps::RateEstimatePackageOptions.new(
        package_id: package.id,
        shipping_method: shipping_method
      )
    end

    it 'uses correct shipping_method' do
      expect(node.at_xpath('Service').text).to eq('PRIORITY')
    end

    context 'with commercial_pricing true' do
      let(:package_options) do
        FriendlyShipping::Services::Usps::RateEstimatePackageOptions.new(
          package_id: package.id,
          shipping_method: shipping_method,
          commercial_pricing: true
        )
      end

      it 'uses correct shipping_method' do
        expect(node.at_xpath('Service').text).to eq('PRIORITY COMMERCIAL')
      end
    end
  end

  context 'with first class mail type' do
    let(:package_options) do
      FriendlyShipping::Services::Usps::RateEstimatePackageOptions.new(
        package_id: package.id,
        first_class_mail_type: :letter
      )
    end

    it 'uses correct first class mail type' do
      expect(node.at_xpath('FirstClassMailType').text).to eq('LETTER')
    end
  end

  context 'with large package' do
    # Package is considered large if any dimension exceeds 12 in
    let(:dimensions) { [35, 21.321539, 24].map { |e| Measured::Length(e, :cm) } }

    it 'uses correct size code' do
      expect(node.at_xpath('Size').text).to eq('LARGE')
    end
  end

  context 'with transmit_dimensions set to false' do
    let(:package_options) do
      FriendlyShipping::Services::Usps::RateEstimatePackageOptions.new(
        package_id: package.id,
        transmit_dimensions: false
      )
    end

    it 'does not transmit dimensions' do
      expect(node.at_xpath('Width')).to be nil
      expect(node.at_xpath('Length')).to be nil
      expect(node.at_xpath('Height')).to be nil
      expect(node.at_xpath('Girth')).to be nil
    end
  end
end
