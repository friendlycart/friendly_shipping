# frozen_string_literal: true

RSpec.describe FriendlyShipping::Services::Usps::ChoosePackageRate do
  let(:shipping_method) do
    FriendlyShipping::Services::Usps::SHIPPING_METHODS.detect do |shipping_method|
      shipping_method.name == shipping_method_name
    end
  end
  let(:shipping_method_name) { 'Priority Mail Express' }
  let(:shipment) { FactoryBot.build(:physical_shipment, packages: [package]) }
  let(:package_id) { '0' }
  let(:package) { FactoryBot.build(:physical_package, id: package_id, container: container) }
  let(:container) { FactoryBot.build(:physical_box, properties: properties) }
  let(:properties) { {} }
  let(:xml) { File.open(File.join(gem_root, 'spec', 'fixtures', 'usps', 'usps_rates_api_response.xml')).read }
  let(:rate_nodes) { Nokogiri::XML(xml).xpath('//Postage') }
  let(:rates) { rate_nodes.map { |node| FriendlyShipping::Services::Usps::ParseRate.call(node, package) } }

  subject { described_class.call(shipping_method, package, rates) }

  it { is_expected.to be_a(FriendlyShipping::Rate) }

  it 'has the right attributes' do
    expect(subject.shipping_method).to eq(shipping_method)
    expect(subject.total_amount.to_f).to eq(36.6)
    expect(subject.data[:box_name]).to be_nil
    expect(subject.data[:hold_for_pickup]).to be false
  end

  context 'if requesting a hold_for_pickup rate' do
    let(:properties) { { hold_for_pickup: true } }

    it 'has the right attributes' do
      expect(subject.shipping_method).to eq(shipping_method)
      expect(subject.total_amount.to_f).to eq(36.6)
      expect(subject.data[:box_name]).to be_nil
      expect(subject.data[:hold_for_pickup]).to be true
    end
  end

  context 'if requesting a rate for a special box type' do
    # There are no rates for Priority Mail Express and Large Flat Rate Box
    let(:shipping_method_name) { 'Priority' }
    let(:properties) { { box_name: :large_flat_rate_box } }

    it 'has the right attributes' do
      expect(subject.shipping_method).to eq(shipping_method)
      expect(subject.total_amount.to_f).to eq(17.9)
      expect(subject.data[:box_name]).to eq(:large_flat_rate_box)
      expect(subject.data[:hold_for_pickup]).to be false
    end
  end
end
