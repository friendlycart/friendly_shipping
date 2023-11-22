# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::ApiError do
  describe "#message" do
    let(:body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ship_engine', fixture)) }
    let(:error) { RestClient::Exception.new(double(body: body, code: 400)) }

    subject { described_class.new(error).message }

    context "with API error response" do
      let(:fixture) { "invalid_package_code.json" }
      it { is_expected.to eq("invalid package_code 'not_a_usps_package_code'") }
    end

    context "with timeout error response" do
      let(:error) { RestClient::Exceptions::ReadTimeout.new("Timed out reading data from server") }
      it { is_expected.to eq("Timed out reading data from server") }
    end
  end
end
