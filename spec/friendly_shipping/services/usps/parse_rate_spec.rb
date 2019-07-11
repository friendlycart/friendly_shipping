# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps::ParseRate do
  let(:package) { FactoryBot.build(:physical_package) }
  let(:mail_service) { "Priority Mail Express 1-Day&lt;sup&gt;&#8482;&lt;/sup&gt;" }
  let(:rate) { "26.40" }
  let(:commercial_rate) { nil }
  let(:commercial_plus_rate) { nil }
  let(:class_id) { '0' }

  subject { described_class.call(node, package) }

  let(:node) do
    serialized = Nokogiri::XML::Builder.new do |xml|
      xml.Postage('CLASSID' => class_id) do
        xml.MailService mail_service
        xml.Rate rate
        xml.CommercialRate commercial_rate if commercial_rate
        xml.CommercialPlusRate commercial_plus_rate if commercial_plus_rate
      end
    end.to_xml
    Nokogiri::XML(serialized).xpath('Postage').first
  end

  it 'parses correctly' do
    expect(subject.total_amount.to_f).to eq(26.4)
    expect(subject.amounts.keys).to eq([package.id])
    expect(subject.shipping_method.name).to eq("Priority Mail Express")
    expect(subject.data[:days_to_delivery]).to eq(1)
    expect(subject.data[:service_code]).to eq('0')
  end

  context 'with a non-express Priority Mail rate' do
    let(:mail_service) { "Priority Mail 2-Day&lt;sup&gt;&#8482;&lt;/sup&gt;" }

    it 'has the correct shipping method' do
      expect(subject.shipping_method.name).to eq('Priority')
    end
  end

  context 'Priority Mail in a Flat Rate Box' do
    let(:class_id) { "1" }
    let(:mail_service) { "Priority Mail 2-Day&lt;sup&gt;&#8482;&lt;/sup&gt; Large Flat Rate Box" }

    it 'contains the box code in the rate data' do
      expect(subject.data[:box_name]).to eq(:large_flat_rate_box)
    end
  end

  context 'First-Class Mail' do
    let(:mail_service) { "First-Class Mail&lt;sup&gt;&#174;&lt;/sup&gt; Parcel" }

    it 'finds a shipping method' do
      expect(subject.shipping_method.name).to eq('First-Class')
      expect(subject.data[:box_name]).to eq(:parcel)
    end
  end

  context 'If Rate is 0' do
    let(:rate) { '0.0' }
    let(:commercial_rate) { '4.50' }

    it 'will use the commercial rate instead of the normal rate' do
      expect(subject.total_amount.to_f).to eq(4.5)
    end
  end
end
