# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::ApiError do
  describe "#message" do
    let(:body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ups_freight', fixture)) }
    let(:error) { RestClient::Exception.new(double(body: body)) }

    subject { described_class.new(error).message }

    context "with HTTP error response" do
      let(:fixture) { "failure_with_multiple_errors.json" }
      it { is_expected.to eq("9360721: Missing or Invalid Attention name in the request.\n9370701: Invalid processing option.") }
    end

    context "with API error response" do
      let(:fixture) { "failure_with_http_error.json" }
      it { is_expected.to eq("400 Bad Request: The body of the request, which was expected to be JSON, was invalid.") }
    end

    context "with timeout error response" do
      let(:error) { RestClient::Exceptions::ReadTimeout.new("Timed out reading data from server") }
      it { is_expected.to eq("Timed out reading data from server") }
    end
  end
end
