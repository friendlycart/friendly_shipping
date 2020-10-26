# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps::ParseRateResponse do
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'usps', 'usps_rates_api_response.xml')).read }
  let(:response) { double(body: response_body) }
  let(:request) { FriendlyShipping::Request.new(url: 'http://www.example.com') }
  let(:packages) do
    [
      FactoryBot.build(:physical_package, id: '0'),
    ]
  end
  let(:shipment) { FactoryBot.build(:physical_shipment, packages: packages) }
  let(:options) do
    FriendlyShipping::Services::Usps::RateEstimateOptions.new(
      package_options: shipment.packages.map do |package|
        FriendlyShipping::Services::Usps::RateEstimatePackageOptions.new(
          package_id: package.id
        )
      end
    )
  end
  subject { described_class.call(request: request, response: response, shipment: shipment, options: options) }

  it { is_expected.to be_success }

  it 'returns rates along with the response' do
    expect(subject.value!.data.length).to eq(4)
    expect(subject.value!.data.map(&:total_amount)).to contain_exactly(*[
      276, 673, 715, 3660
    ].map { |cents| Money.new(cents, 'USD') })
    expect(subject.value!.data.map(&:shipping_method).map(&:name)).to contain_exactly(
      "First-Class",
      "Priority Mail",
      "Priority Mail Express",
      "Standard Post"
    )
  end

  context 'with response for one regional rate box' do
    let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'usps', 'rates_api_response_regional_single.xml')).read }
    let(:packages) do
      [
        FactoryBot.build(:physical_package, id: '0'),
      ]
    end
    let(:options) do
      FriendlyShipping::Services::Usps::RateEstimateOptions.new(
        package_options: shipment.packages.map do |package|
          FriendlyShipping::Services::Usps::RateEstimatePackageOptions.new(
            package_id: package.id,
            box_name: :regional_rate_box_b
          )
        end
      )
    end

    it 'returns regional rate' do
      expect(subject).to be_success
      expect(subject.value!.data.length).to eq(1)
      expect(subject.value!.data.first.total_amount.to_f).to eq(9.4)
      expect(subject.value!.data.first.data[:full_mail_service]).to eq('Priority Mail 2-Day Regional Rate Box B')
    end
  end

  context 'with response for multiple regional rate boxes' do
    let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'usps', 'rates_api_response_regional_multiple.xml')).read }
    let(:packages) do
      [
        FactoryBot.build(:physical_package, id: '0', container: regional_rate_box_a),
        FactoryBot.build(:physical_package, id: '1', container: regional_rate_box_b),
      ]
    end
    let(:regional_rate_box_a) { FactoryBot.build(:physical_box, properties: { box_name: :regional_rate_box_a } ) }
    let(:regional_rate_box_b) { FactoryBot.build(:physical_box, properties: { box_name: :regional_rate_box_b } ) }
    let(:options) do
      FriendlyShipping::Services::Usps::RateEstimateOptions.new(
        package_options: shipment.packages.map do |package|
          FriendlyShipping::Services::Usps::RateEstimatePackageOptions.new(
            package_id: package.id,
            box_name: package.properties[:box_name]
          )
        end
      )
    end

    it 'returns regional rates' do
      expect(subject).to be_success
      expect(subject.value!.data.length).to eq(1)

      expect(subject.value!.data.map(&:total_amount).map(&:cents)).to contain_exactly(812 + 940)
      expect(subject.value!.data.map(&:shipping_method).map(&:name)).to contain_exactly(
        "Priority Mail"
      )
    end
  end

  context 'with response containing large flat rates' do
    let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'usps', 'rates_api_response_large_box.xml')).read }
    let(:packages) do
      [
        FactoryBot.build(:physical_package, id: '0'),
      ]
    end
    let(:options) do
      FriendlyShipping::Services::Usps::RateEstimateOptions.new(
        package_options: shipment.packages.map do |package|
          FriendlyShipping::Services::Usps::RateEstimatePackageOptions.new(
            package_id: package.id,
            box_name: :large_flat_rate_box,
            commercial_pricing: true
          )
        end
      )
    end

    it 'returns flat rate' do
      expect(subject).to be_success
      expect(subject.value!.data.length).to eq(1)
      expect(subject.value!.data.first.total_amount.to_f).to eq(17.6)
      expect(subject.value!.data.first.data[:full_mail_service]).to eq('Priority Mail 3-Day Large Flat Rate Box')
    end
  end
end
