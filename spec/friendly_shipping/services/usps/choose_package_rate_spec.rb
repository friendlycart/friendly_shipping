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
  let(:package) { FactoryBot.build(:physical_package, id: package_id) }
  let(:xml) { File.open(File.join(gem_root, 'spec', 'fixtures', 'usps', 'usps_rates_api_response.xml')).read }
  let(:rate_nodes) { Nokogiri::XML(xml).xpath('//Postage') }
  let(:rates) { rate_nodes.map { |node| FriendlyShipping::Services::Usps::ParseRate.call(node, package) } }

  subject { described_class.call(shipping_method, package, rates) }

  it { is_expected.to be_a(FriendlyShipping::Rate) }
end
