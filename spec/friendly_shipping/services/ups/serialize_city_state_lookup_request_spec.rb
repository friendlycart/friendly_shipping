# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::SerializeCityStateLookupRequest do
  let(:location) { Physical::Location.new(zip: '27587', country: 'US') }

  describe '#to_xml' do
    subject { Nokogiri::XML(described_class.call(location: location)) }

    it 'has the right data in the right places' do
      expect(subject.at_xpath('//AddressValidationRequest')).to be_present
      expect(subject.at_xpath('//AddressValidationRequest/Request/RequestAction').text).to eq('AV')
      expect(subject.at_xpath('//AddressValidationRequest/Address/PostalCode').text).to eq('27587')
      expect(subject.at_xpath('//AddressValidationRequest/Address/CountryCode').text).to eq('US')
    end
  end
end
