# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Reconex::ApiError do
  describe "#message" do
    subject(:message) { described_class.new(error).message }

    context "with API error response" do
      let(:body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'reconex', 'failure.json')) }
      let(:error) { RestClient::Exception.new(double(body: body, code: 400)) }

      it { is_expected.to eq("Origin postal code is required, Destination postal code is required") }
    end

    context "with unparseable response body" do
      let(:error) { RestClient::Exception.new(double(body: "not json", code: 500)) }

      it { is_expected.to eq("RestClient::Exception") }
    end

    context "with no response" do
      let(:error) { RestClient::Exceptions::ReadTimeout.new("Timed out reading data from server") }

      it { is_expected.to eq("Timed out reading data from server") }
    end
  end
end
