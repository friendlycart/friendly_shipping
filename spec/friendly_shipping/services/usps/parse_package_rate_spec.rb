# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps::ParsePackageRate do
  let(:package) { FactoryBot.build(:physical_package) }
  let(:mail_service) { "Priority Mail Express 1-Day&lt;sup&gt;&#8482;&lt;/sup&gt;" }
  let(:rate) { "26.40" }
  let(:commercial_rate) { nil }
  let(:commercial_plus_rate) { nil }
  let(:class_id) { "3" }
  let(:package_options) do
    FriendlyShipping::Services::Usps::RateEstimatePackageOptions.new(
      package_id: package.id
    )
  end
  subject { described_class.call(node, package, package_options) }

  let(:node) do
    serialized = Nokogiri::XML::Builder.new do |xml|
      xml.Postage('CLASSID' => class_id) do
        xml.MailService mail_service
        xml.Rate rate
        xml.CommercialRate commercial_rate if commercial_rate
        xml.CommercialPlusRate commercial_plus_rate if commercial_plus_rate
        xml.Fees do
          xml.Fee do
            xml.FeeType "Nonstandard Length fee &gt; 30 in."
            xml.FeePrice "15.00"
          end
          xml.Fee do
            xml.FeeType "Nonstandard Volume fee &gt; 2 cu. ft."
            xml.FeePrice "15.00"
          end
        end
      end
    end.to_xml
    Nokogiri::XML(serialized).xpath('Postage').first
  end

  it 'parses correctly' do
    expect(subject.total_amount.to_f).to eq(26.4)
    expect(subject.amounts.keys).to eq([package.id])
    expect(subject.shipping_method.name).to eq("Priority Mail Express")
    expect(subject.data[:days_to_delivery]).to eq(1)
    expect(subject.data[:service_code]).to eq("3")
    expect(subject.data[:fees]).to eq(
      [
        {
          type: "Nonstandard Length fee &gt; 30 in.",
          price: Money.new("1500", "USD")
        },
        {
          type: "Nonstandard Volume fee &gt; 2 cu. ft.",
          price: Money.new("1500", "USD")
        }
      ]
    )
  end

  context 'with a non-express Priority Mail rate' do
    let(:class_id) { "1" }
    let(:mail_service) { "Priority Mail 2-Day&lt;sup&gt;&#8482;&lt;/sup&gt;" }

    it 'has the correct shipping method' do
      expect(subject.shipping_method.name).to eq('Priority Mail')
      expect(subject.data[:service_code]).to eq("1")
    end
  end

  context "Priority Mail Express Hold for Pickup" do
    let(:class_id) { "2" }
    let(:mail_service) { "Priority Mail Express 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Hold For Pickup" }

    it "has the correct shipping method" do
      expect(subject.shipping_method.name).to eq("Priority Mail Express")
      expect(subject.data[:service_code]).to eq("2")
    end
  end

  context "Priority Mail Express Saturday/Holiday delivery" do
    let(:class_id) { "23" }
    let(:mail_service) { "Priority Mail Express 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Sunday/Holiday Delivery" }

    it "has the correct shipping method" do
      expect(subject.shipping_method.name).to eq("Priority Mail Express")
      expect(subject.data[:service_code]).to eq("23")
    end
  end

  context "Priority Mail Cubic" do
    let(:class_id) { "999" }
    let(:mail_service) { "Priority Mail 2-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Cubic" }

    it "has the correct shipping method" do
      expect(subject.shipping_method.name).to eq("Priority Mail Cubic")
      expect(subject.data[:service_code]).to eq("999")
    end
  end

  context 'Priority Mail in a Flat Rate Box' do
    let(:class_id) { "22" }
    let(:mail_service) { "Priority Mail 2-Day&lt;sup&gt;&#8482;&lt;/sup&gt; Large Flat Rate Box" }

    it "has the correct shipping method" do
      expect(subject.shipping_method.name).to eq("Priority Mail")
      expect(subject.data[:box_name]).to eq(:large_flat_rate_box)
      expect(subject.data[:service_code]).to eq("22")
    end
  end

  context 'First-Class Mail' do
    let(:class_id) { "0" }
    let(:mail_service) { "First-Class Mail&lt;sup&gt;&#174;&lt;/sup&gt; Parcel" }

    it "has the correct shipping method" do
      expect(subject.shipping_method.name).to eq('First-Class')
      expect(subject.data[:box_name]).to eq(:parcel)
      expect(subject.data[:service_code]).to eq("0")
    end
  end

  context 'If Rate is 0' do
    let(:rate) { '0.0' }
    let(:commercial_rate) { '4.50' }

    it 'will use the commercial rate instead of the normal rate' do
      expect(subject.total_amount.to_f).to eq(4.5)
    end
  end

  context "if rate is 0 and commercial rate is missing" do
    let(:rate) { "0.0" }
    let(:commercial_plus_rate) { "5.70" }

    it "uses commercial plus rate" do
      expect(subject.total_amount.to_f).to eq(5.7)
    end
  end
end
