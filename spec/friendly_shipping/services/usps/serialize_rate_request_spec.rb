# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps::SerializeRateRequest do
  let(:dimensions) { [10, 21.321539, 24].map { |e| Measured::Length(e, :cm) } }
  let(:weight) { Measured::Weight.new(14.025, :ounces) }
  let(:properties) { {} }
  let(:container) { FactoryBot.build(:physical_box, dimensions: dimensions, weight: weight, properties: properties) }
  let(:package) { FactoryBot.build(:physical_package, container: container, items: [], void_fill_density: Measured::Weight(0, :g)) }
  let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package]) }
  let(:shipping_method) { nil }
  subject(:parser) { described_class.call(shipment: shipment, login: 'fake', shipping_method: shipping_method) }

  let(:node) { Nokogiri::XML(subject).xpath('//RateV4Request/Package') }

  it 'serializes the request' do
    expect(node.at_xpath('Service').text).to eq('ALL')
    expect(node.at_xpath('Container').text).to eq('RECTANGULAR')
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
    let(:properties) { { box_name: :regional_rate_box_a } }

    it 'uses correct container' do
      expect(node.at_xpath('Container').text).to eq('REGIONALRATEBOXA')
    end
  end

  context 'with large flat rate box name' do
    let(:properties) { { box_name: :large_flat_rate_box } }

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

    it 'uses correct shipping_method' do
      expect(node.at_xpath('Service').text).to eq('PRIORITY')
    end

    context 'with commercial_pricing true' do
      let(:properties) { { commercial_pricing: true } }

      it 'uses correct shipping_method' do
        expect(node.at_xpath('Service').text).to eq('PRIORITY COMMERCIAL')
      end
    end
  end
end
