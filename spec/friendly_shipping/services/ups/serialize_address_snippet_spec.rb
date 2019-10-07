# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::SerializeAddressSnippet do
  let(:context_root) { "ShipTo" }

  subject do
    Nokogiri::XML::Builder.new do |xml|
      xml.send(context_root) do
        described_class.call(xml: xml, location: location)
      end
    end.doc
  end

  let(:location) do
    FactoryBot.build(:physical_location, company_name: 'A very nice company', phone: "0998877665", zip: '00001')
  end

  it 'adds a address to the context' do
    expect(subject.at_xpath('//ShipTo')).to be_present
    expect(subject.at_xpath('//ShipTo/CompanyName').text).to eq('A very nice company')
    expect(subject.at_xpath('//ShipTo/AttentionName').text).to eq('Jane Doe')
    expect(subject.at_xpath('//ShipTo/PhoneNumber').text).to eq('0998877665')
    expect(subject.at_xpath('//ShipTo/Address/AddressLine1').text).to eq('11 Lovely Street')
    expect(subject.at_xpath('//ShipTo/Address/AddressLine2').text).to eq('South')
    expect(subject.at_xpath('//ShipTo/Address/City').text).to eq('Herndon')
    expect(subject.at_xpath('//ShipTo/Address/PostalCode').text).to eq('00001')
    expect(subject.at_xpath('//ShipTo/Address/StateProvinceCode').text).to eq('IL')
    expect(subject.at_xpath('//ShipTo/Address/CountryCode').text).to eq('US')
    expect(subject.at_xpath('//ShipTo/Address/ResidentialAddressIndicator')).to be_present
  end

  context 'when the address is not a business address' do
    let(:location) do
      FactoryBot.build(:physical_location, company_name: nil, phone: "0998877665")
    end

    it 'uses the recipient name for the CompanyName column' do
      expect(subject.at_xpath('//ShipTo')).to be_present
      expect(subject.at_xpath('//ShipTo/CompanyName').text).to eq('Jane Doe')
      expect(subject.at_xpath('//ShipTo/AttentionName')).to be nil
      expect(subject.at_xpath('//ShipTo/PhoneNumber').text).to eq('0998877665')
    end
  end

  context 'when context is "Shipper"' do
    let(:context_root) { "Shipper" }

    it 'uses the "Name" instead of the "CompanyName" tag' do
      expect(subject.at_xpath('//Shipper/Name').text).to eq('A very nice company')
      expect(subject.at_xpath('//Shipper/CompanyName')).not_to be_present
    end
  end

  context 'with very long fields' do
    let(:location) do
      FactoryBot.build(:physical_location, company_name: "Stephanie's Specialty Soaps and More!", phone: "0998877665")
    end

    it 'shortens these strings in ways that makes sense' do
      expect(subject.at_xpath('//ShipTo/CompanyName').text).to eq("Stephanie's Specialty Soaps and Mor")
    end
  end
end
