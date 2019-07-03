# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::SerializeAccessRequest do
  subject { Nokogiri::XML(described_class.(key: 'SECRETKEY', login: 'SECRETLOGIN', password: 'S3Cr3T')) }

  it 'has the right data in the right places' do
    expect(subject.at_xpath('//AccessRequest')).to be_present
    expect(subject.at_xpath('//AccessRequest/AccessLicenseNumber').text).to eq('SECRETKEY')
    expect(subject.at_xpath('//AccessRequest/UserId').text).to eq('SECRETLOGIN')
    expect(subject.at_xpath('//AccessRequest/Password').text).to eq('S3Cr3T')
  end
end
