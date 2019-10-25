# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::SerializeAddressValidationRequest do
  let(:location) { FactoryBot.build(:physical_location, zip: '10123') }

  describe '#to_xml' do
    subject { Nokogiri::XML(described_class.call(location: location)) }

    it 'has the right data in the right places' do
      expect(subject.at_xpath('//AddressValidationRequest')).to be_present
      expect(subject.at_xpath('//AddressValidationRequest/Request/RequestAction').text).to eq('XAV')
      expect(subject.at_xpath('//AddressValidationRequest/Request/RequestOption').text).to eq('3')
      expect(subject.at_xpath('//AddressValidationRequest/AddressKeyFormat/ConsigneeName').text).to eq('Company')
      expect(subject.at_xpath('//AddressValidationRequest/AddressKeyFormat/AddressLine[1]').text).to eq('11 Lovely Street')
      expect(subject.at_xpath('//AddressValidationRequest/AddressKeyFormat/AddressLine[2]').text).to eq('South')
      expect(subject.at_xpath('//AddressValidationRequest/AddressKeyFormat/PoliticalDivision1').text).to eq('IL')
      expect(subject.at_xpath('//AddressValidationRequest/AddressKeyFormat/PoliticalDivision2').text).to eq('Herndon')
      expect(subject.at_xpath('//AddressValidationRequest/AddressKeyFormat/PostcodePrimaryLow').text).to eq('10123')
      expect(subject.at_xpath('//AddressValidationRequest/AddressKeyFormat/CountryCode').text).to eq('US')
    end

    context 'with location that has no company name' do
      let(:location) { FactoryBot.build(:physical_location, company_name: nil) }

      it 'uses name as consignee fallback' do
        expect(subject.at_xpath('//AddressValidationRequest/AddressKeyFormat/ConsigneeName').text).to eq('Jane Doe')
      end
    end
  end
end
