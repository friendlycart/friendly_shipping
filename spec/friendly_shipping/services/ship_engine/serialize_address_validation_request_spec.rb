# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::SerializeAddressValidationRequest do
  subject(:call) { described_class.call(location: location) }

  let(:location) do
    Physical::Location.new(
      company_name: "ACME Inc",
      name: "John Smith",
      email: "john@acme.com",
      phone: "123-123-1234",
      address1: "123 Maple St",
      address2: "Suite 456",
      city: "Richmond",
      zip: "23224",
      region: "VA",
      country: "US",
      address_type: "residential"
    )
  end

  it do
    is_expected.to eq(
      [
        {
          name: "John Smith",
          phone: "123-123-1234",
          email: "john@acme.com",
          company_name: "ACME Inc",
          address_line1: "123 Maple St",
          address_line2: "Suite 456",
          address_line3: nil,
          city_locality: "Richmond",
          state_province: "VA",
          postal_code: "23224",
          country_code: "US",
          address_residential_indicator: "yes"
        }
      ]
    )
  end
end
