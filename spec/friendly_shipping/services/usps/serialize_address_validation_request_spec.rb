# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps::SerializeAddressValidationRequest do
  let(:location) do
    FactoryBot.build(
      :physical_location,
      address1: '12 Maple St',
      address2: 'Apt 50',
      city: 'Statesville',
      region: 'NY',
      zip: '14153'
    )
  end

  subject { Nokogiri::XML(described_class.call(location: location, login: 'secret')) }

  it 'has the right data in the right places' do
    node = subject.xpath('//AddressValidateRequest')
    expect(node.attr('USERID').value).to eq('secret')
    expect(node.at_xpath('Address/Address1').text).to eq('Apt 50')
    expect(node.at_xpath('Address/Address2').text).to eq('12 Maple St')
    expect(node.at_xpath('Address/City').text).to eq('Statesville')
    expect(node.at_xpath('Address/State').text).to eq('NY')
    expect(node.at_xpath('Address/Zip5').text).to eq('14153')
    expect(node.at_xpath('Address/Zip4').text).to eq('')
  end
end
