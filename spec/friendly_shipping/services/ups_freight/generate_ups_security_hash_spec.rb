# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/generate_ups_security_hash'

RSpec.describe FriendlyShipping::Services::UpsFreight::GenerateUpsSecurityHash do
  subject { JSON.parse(described_class.call(login: 'my_login', password: 'secret', key: 'ups_key').to_json) }

  it 'has the right things in the right places' do
    is_expected.to include(
      "UPSSecurity" => {
        "UsernameToken" => {
          "Username" => 'my_login',
          "Password" => 'secret'
        },
        "ServiceAccessToken" => {
          "AccessLicenseNumber" => 'ups_key'
        }
      }
    )
  end
end
