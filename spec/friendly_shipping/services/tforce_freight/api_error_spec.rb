# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::ApiError do
  describe "#message" do
    subject(:message) { described_class.new(error).message }

    let(:body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'tforce_freight', fixture)) }
    let(:error) { RestClient::Exception.new(double(body: body)) }

    context "with API error response" do
      let(:fixture) { "failure_with_api_error.json" }
      it { is_expected.to eq("502: Rate requires assistance from Customer Service (800-333-7400)") }
    end

    context "with HTTP error response" do
      let(:fixture) { "failure_with_http_error.json" }

      it do
        is_expected.to eq(
          "400: Body of the request does not conform to the definition which is associated with the content " \
          "type application/json. Invalid type. Expected String but got Null. Line: 1, Position: 398"
        )
      end
    end

    context "with timeout error response" do
      let(:error) { RestClient::Exceptions::ReadTimeout.new("Timed out reading data from server") }
      it { is_expected.to eq("Timed out reading data from server") }
    end
  end
end
