# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UspsInternational::SerializeRateRequest do
  let(:country) { Carmen::Country.named("Canada") }
  let(:destination) { FactoryBot.build(:physical_location, country: country, region: country.subregions.coded("AB"), address1: '15 7 Ave', zip: 'T0A3J0') }
  let(:origin) { FactoryBot.build(:physical_location, region: "NC", zip: '27704') }
  let(:dimensions) { [10, 21.321539, 24].map { |e| Measured::Length(e, :cm) } }
  let(:weight) { Measured::Weight.new(14.025, :ounces) }
  let(:properties) { {} }
  let(:container) { FactoryBot.build(:physical_box, dimensions: dimensions, weight: weight) }
  let(:package) { FactoryBot.build(:physical_package, container: container, items: [], void_fill_density: Measured::Density(0, :g_ml)) }
  let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package], origin: origin, destination: destination) }
  let(:options) { FriendlyShipping::Services::UspsInternational::RateEstimateOptions.new(package_options: [package_options]) }
  let(:package_options) { FriendlyShipping::Services::UspsInternational::RateEstimatePackageOptions.new(package_id: package.id) }
  subject(:parser) { described_class.call(shipment: shipment, login: 'fake', options: options) }

  let(:node) { Nokogiri::XML(subject).xpath('//IntlRateV2Request/Package') }

  it 'serializes the request' do
    expect(node.at_xpath('Pounds').text).to eq('0')
    expect(node.at_xpath('Ounces').text).to eq('15')
    expect(node.at_xpath('Machinable').text).to eq('false')
    expect(node.at_xpath('MailType').text).to eq('ALL')
    expect(node.at_xpath('Country').text).to eq('Canada')
    expect(node.at_xpath('Container').text).to eq('VARIABLE')
    expect(node.at_xpath('Width').text).to eq('8.39')
    expect(node.at_xpath('Length').text).to eq('3.94')
    expect(node.at_xpath('Height').text).to eq('9.45')
    expect(node.at_xpath('Girth')).to be nil
    expect(node.at_xpath('CommercialFlag').text).to eq('N')
    expect(node.at_xpath('CommercialPlusFlag').text).to eq('N')
  end

  context 'with package weight that ceils to exactly 16 oz' do
    let(:weight) { Measured::Weight(15.6, :ounces) }

    it 'returns 15.999 oz' do
      expect(node.at_xpath('Ounces').text).to eq('15.999')
    end
  end

  context 'ounces of package weight does not include pounds' do
    let(:weight) { Measured::Weight(40.5, :pounds) }

    it 'returns 40 pounds and 8 ounces' do
      expect(node.at_xpath('Pounds').text).to eq('40')
      expect(node.at_xpath('Ounces').text).to eq('8')
    end
  end

  context 'with rectangular false' do
    let(:package_options) do
      FriendlyShipping::Services::UspsInternational::RateEstimatePackageOptions.new(
        package_id: package.id,
        rectangular: false
      )
    end

    it 'includes girth' do
      expect(node.at_xpath('Girth').text).to eq('24.66')
    end
  end

  context 'with transmit_dimensions set to false' do
    let(:package_options) do
      FriendlyShipping::Services::UspsInternational::RateEstimatePackageOptions.new(
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
