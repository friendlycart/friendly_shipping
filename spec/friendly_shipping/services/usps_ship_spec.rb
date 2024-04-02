# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip do
  subject(:service) { described_class.new(access_token: access_token) }

  let(:access_token) do
    FriendlyShipping::Services::USPSShip::AccessToken.new(
      token_type: "Bearer",
      expires_in: 3599,
      raw_token: "secret_token"
    )
  end

  describe "#carriers" do
    subject(:carriers) { service.carriers }
    it { is_expected.to be_success }
    it { expect(carriers.value!).to eq([FriendlyShipping::Services::USPSShip::CARRIER]) }
  end

  describe "#create_access_token" do
    subject(:create_access_token) do
      service.create_access_token(
        client_id: "client-id",
        client_secret: "client-secret"
      )
    end

    let(:response) do
      instance_double(
        RestClient::Response,
        code: 200,
        body: %({
          "token_type": "Bearer",
          "expires_in": 3599,
          "access_token": "XYADfw4Hz2KdN_sd8N4TzMo9"
        }),
        headers: {
          "Cache-Control" => "no-store, no-cache",
          "Content-Type" => "application/json; charset=utf-8"
        }
      )
    end

    before do
      expect(RestClient).to receive(:post).with(
        "https://api.usps.com/oauth2/v3/token",
        "client_id=client-id&client_secret=client-secret&grant_type=client_credentials",
        { Accept: "application/json", Content_Type: "application/x-www-form-urlencoded" }
      ).and_return(response)
    end

    it "makes API request and returns access token" do
      result = create_access_token
      expect(result).to be_success
      expect(result.value!).to be_a(FriendlyShipping::ApiResult)

      access_token = result.value!.data
      expect(access_token).to be_a(FriendlyShipping::Services::USPSShip::AccessToken)
      expect(access_token.token_type).to eq("Bearer")
      expect(access_token.expires_in).to eq(3599)
      expect(access_token.raw_token).to eq("XYADfw4Hz2KdN_sd8N4TzMo9")
    end
  end
end
