# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::ParsePickupResponse do
  describe ".call" do
    subject(:call) { described_class.call(request: nil, response: response) }

    let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "tforce_freight", "create_pickup", "success.json")) }
    let(:response) { double(body: response_body) }

    it "has the right data" do
      expect(call.data).to eq(
        confirmation_number: "WBU5337790",
        destination_is_rural: "false",
        email_sent: "false",
        origin_is_rural: "false",
        response_status_code: "1",
        response_status_description: "Success",
        transaction_id: "7acf9c09-55f0-41a4-9371-9caafd63d618",
      )
    end
  end
end
