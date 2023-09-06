# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UspsInternational::ParseRateResponse do
  let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'usps_international', 'rates_api_response.xml')) }
  let(:response) { double(body: response_body) }
  let(:request) { FriendlyShipping::Request.new(url: 'http://www.example.com') }
  let(:packages) do
    [
      FactoryBot.build(:physical_package, id: '0'),
    ]
  end
  let(:shipment) { FactoryBot.build(:physical_shipment, packages: packages) }
  let(:options) do
    FriendlyShipping::Services::UspsInternational::RateEstimateOptions.new(
      package_options: shipment.packages.map do |package|
        FriendlyShipping::Services::UspsInternational::RateEstimatePackageOptions.new(
          package_id: package.id
        )
      end
    )
  end
  subject { described_class.call(request: request, response: response, shipment: shipment, options: options) }

  it { is_expected.to be_success }

  it 'returns rates along with the response' do
    expect(subject.value!.data.length).to eq(7)
    expect(subject.value!.data.map(&:total_amount)).to contain_exactly(*[
      8505, 5850, 4210, 7400, 6055, 2340, 5610
    ].map { |cents| Money.new(cents, 'USD') })
    expect(subject.value!.data.map(&:shipping_method).map(&:name)).to contain_exactly(
      "USPS GXG; Envelopes",
      "Airmail M-Bag",
      "First-Class Package International Service",
      "Priority Mail Express International",
      "Priority Mail International",
      "Priority Mail International; Large Flat Rate Box",
      "Priority Mail International; Medium Flat Rate Box",
    )
  end
end
