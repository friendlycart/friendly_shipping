# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/generate_location_hash'

RSpec.describe FriendlyShipping::Services::UpsFreight::GenerateLocationHash do
  let(:location) do
    Physical::Location.new(
      company_name: 'Developer Test 1',
      address1: '01 Developer Way',
      address2: 'North',
      address3: 'In the Attic',
      city: 'Richmond',
      zip: '23224',
      region: 'VA',
      country: 'US'
    )
  end

  subject { described_class.call(location: location) }

  it 'has all the right things' do
    is_expected.to eq(
      Name: 'Developer Test 1',
      Address: {
        AddressLine: '01 Developer Way, North, In the Attic',
        City: 'Richmond',
        StateProvinceCode: 'VA',
        PostalCode: '23224',
        CountryCode: 'US'
      }
    )
  end

  context 'with a phone number' do
    let(:location) do
      Physical::Location.new(
        company_name: 'Developer Test 1',
        address1: '01 Developer Way',
        address2: 'North',
        address3: 'In the Attic',
        phone: '999999999',
        city: 'Richmond',
        zip: '23224',
        region: 'VA',
        country: 'US'
      )
    end

    it 'has all the right things' do
      is_expected.to eq(
        Name: 'Developer Test 1',
        Address: {
          AddressLine: '01 Developer Way, North, In the Attic',
          City: 'Richmond',
          StateProvinceCode: 'VA',
          PostalCode: '23224',
          CountryCode: 'US'
        },
        Phone: {
          Number: '999999999'
        }
      )
    end
  end
end
