# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/http_client'

RSpec.describe FriendlyShipping::HttpClient do
  let(:response) { double }

  subject { described_class.new }
  it { is_expected.to respond_to(:error_handler) }

  describe '.get' do
    let(:request) { FriendlyShipping::Request.new(url: 'https://example.com', headers: { "X-Token" => "s3cr3t" }) }
    let(:response) { double(code: 200, body: 'so much text', headers: {}) }

    it 'forwards the arguments to RestClient and returns a Success' do
      expect(::RestClient).to receive(:get).with('https://example.com', "X-Token" => "s3cr3t").and_return(response)
      result = subject.get(request)
      expect(result).to be_success
    end

    it 'wraps exceptions in Failures' do
      expect(::RestClient).to receive(:get).with('https://example.com', "X-Token" => "s3cr3t").and_raise(RestClient::ExceptionWithResponse)
      result = subject.get(request)
      expect(result).to be_failure
      expect(result.failure).to be_a(FriendlyShipping::ApiFailure)
    end
  end

  describe '.post' do
    let(:request) { FriendlyShipping::Request.new(url: 'https://example.com', body: 'body', headers: { "X-Token" => "s3cr3t" }) }
    let(:response) { double(code: 200, body: 'ok', headers: {}) }

    it 'forwards the arguments to RestClient and returns a Success' do
      expect(::RestClient).to receive(:post).with('https://example.com', 'body', "X-Token" => "s3cr3t").and_return(response)
      result = subject.post(request)
      expect(result).to be_success
    end

    it 'wraps exceptions in Failures' do
      expect(::RestClient).to receive(:post).with('https://example.com', 'body', "X-Token" => "s3cr3t").and_raise(RestClient::ExceptionWithResponse)
      result = subject.post(request)
      expect(result).to be_failure
      expect(result.failure).to be_a(FriendlyShipping::ApiFailure)
    end
  end

  describe '.put' do
    let(:request) { FriendlyShipping::Request.new(url: 'https://example.com', body: 'body', headers: { "X-Token" => "s3cr3t" }) }
    let(:response) { double(code: 200, body: 'ok', headers: {}) }

    it 'forwards the arguments to RestClient and returns a Success' do
      expect(::RestClient).to receive(:put).with('https://example.com', 'body', "X-Token" => "s3cr3t").and_return(response)
      result = subject.put(request)
      expect(result).to be_success
    end

    it 'wraps exceptions in Failures' do
      expect(::RestClient).to receive(:put).with('https://example.com', 'body', "X-Token" => "s3cr3t").and_raise(RestClient::ExceptionWithResponse)
      result = subject.put(request)
      expect(result).to be_failure
      expect(result.failure).to be_a(FriendlyShipping::ApiFailure)
    end
  end
end
