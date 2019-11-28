# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::SerializeShipmentAddressSnippet do
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
    expect(subject.at_xpath('//ShipTo/Address/ResidentialAddress')).to be_present
  end

  context 'with commercial address' do
    let(:location) { FactoryBot.build(:physical_location, address_type: 'commercial') }

    it 'includes residential address indicator' do
      expect(subject.at_xpath('//ShipTo/Address/ResidentialAddress')).not_to be_present
    end
  end

  context 'with unknown address' do
    let(:location) { FactoryBot.build(:physical_location, address_type: 'unknown') }

    it 'includes residential address indicator' do
      expect(subject.at_xpath('//ShipTo/Address/ResidentialAddress')).to be_present
    end
  end
end
