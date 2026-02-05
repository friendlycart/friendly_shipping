# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Reconex do
  subject(:service) do
    described_class.new(
      api_key: "test-api-key",
      live_api_base: "https://live.example.com",
      test_api_base: "https://test.example.com"
    )
  end

  describe "initialization" do
    it { is_expected.to respond_to :api_key }
    it { is_expected.to respond_to :test }
    it { is_expected.to respond_to :live_api_base }
    it { is_expected.to respond_to :test_api_base }
    it { is_expected.to respond_to :client }
  end

  describe 'client' do
    subject(:client) { service.client }

    it { is_expected.to be_a(FriendlyShipping::HttpClient) }
    it { expect(client.error_handler).to be_a(FriendlyShipping::ApiErrorHandler) }
    it { expect(client.error_handler.api_error_class).to eq(FriendlyShipping::Services::Reconex::ApiError) }
  end

  describe "test mode" do
    context "when test is true (default)" do
      it "uses the test API base URL" do
        expect(service.send(:api_base)).to eq("https://test.example.com")
      end
    end

    context "when test is false" do
      subject(:service) do
        described_class.new(
          api_key: "test-api-key",
          live_api_base: "https://live.example.com",
          test_api_base: "https://test.example.com",
          test: false
        )
      end

      it "uses the live API base URL" do
        expect(service.send(:api_base)).to eq("https://live.example.com")
      end
    end
  end
end
