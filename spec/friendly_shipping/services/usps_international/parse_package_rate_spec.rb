# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UspsInternational::ParsePackageRate do
  let(:package) { FactoryBot.build(:physical_package) }
  let(:svc_description) { "USPS GXG&lt;sup&gt;&#8482;&lt;/sup&gt; Envelopes" }
  let(:postage) { "26.40" }
  let(:commercial_postage) { nil }
  let(:commercial_plus_postage) { nil }
  let(:class_id) { "12" }
  let(:package_options) do
    FriendlyShipping::Services::UspsInternational::RateEstimatePackageOptions.new(
      package_id: package.id
    )
  end
  subject { described_class.call(node, package, package_options) }

  let(:node) do
    serialized = Nokogiri::XML::Builder.new do |xml|
      xml.Service('ID' => class_id) do
        xml.SvcDescription svc_description
        xml.Postage postage
        xml.CommercialPostage commercial_postage if commercial_postage
        xml.CommercialPlusPostage commercial_plus_postage if commercial_plus_postage
        xml.GuaranteeAvailability('3 - 5 business days to many major markets')
      end
    end.to_xml
    Nokogiri::XML(serialized).xpath('Service').first
  end

  it 'parses correctly' do
    expect(subject.total_amount.to_f).to eq(26.4)
    expect(subject.amounts.keys).to eq([package.id])
    expect(subject.shipping_method.name).to eq("USPS GXG; Envelopes")
    expect(subject.data[:service_code]).to eq("12")
    expect(subject.data[:days_to_delivery]).to eq('3 - 5 business days to many major markets')
  end

  context 'If Postage is 0' do
    let(:postage) { '0.0' }
    let(:commercial_postage) { '4.50' }

    it 'will use the commercial rate instead of the normal rate' do
      expect(subject.total_amount.to_f).to eq(4.5)
    end
  end

  context "if Postage is 0 and CommercialPostage is missing" do
    let(:postage) { "0.0" }
    let(:commercial_plus_postage) { "5.70" }

    it "uses CommercialPlusPostage" do
      expect(subject.total_amount.to_f).to eq(5.7)
    end
  end
end
