# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps::SerializeCityStateLookupRequest do
  let(:location) { Physical::Location.new(zip: '27587', country: 'US') }

  describe '#to_xml' do
    subject { Nokogiri::XML(described_class.call(location: location, login: 'secret')) }

    it 'has the right data in the right places' do
      expect(subject.at_xpath('//CityStateLookupRequest')).to be_present
      expect(subject.at_xpath('//CityStateLookupRequest').attr('USERID')).to eq('secret')
      expect(subject.at_xpath('//CityStateLookupRequest/ZipCode/Zip5').text).to eq('27587')
    end
  end
end
