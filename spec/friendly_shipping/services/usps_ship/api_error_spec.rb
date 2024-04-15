# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip::ApiError do
  describe "#message" do
    subject { described_class.new(error).message }

    context "with API error response" do
      let(:body) { File.read(File.join(gem_root, "spec", "fixtures", "usps_ship", "rate_estimates", "missing_dest_zip.json")) }
      let(:error) { RestClient::Exception.new(double(body: body, code: 400)) }

      it do
        is_expected.to eq(
          "OASValidation OpenAPI-Spec-Validation-Domestic-Prices with resource oas://domestic-prices-v3.yaml: " \
          "failed with reason: [ERROR - [Path '/destinationZIPCode'] Instance type (null) does not match any " \
          "allowed primitive type (allowed: [string]): []]"
        )
      end
    end

    context "with timeout error response" do
      let(:error) { RestClient::Exceptions::ReadTimeout.new("Timed out reading data from server") }
      it { is_expected.to eq("Timed out reading data from server") }
    end
  end
end
