require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::Client do
  let(:response) { double }

  describe '.get' do
    let(:request) { FriendlyShipping::Request.new(url: 'https://example.com', headers: { "X-Token" => "s3cr3t"}) }
    let(:response) { double(code: 200, body: 'so much text', headers: {}) }

    it 'forwards the arguments to RestClient and returns a Success' do
      expect(::RestClient).to receive(:get).with('https://example.com', { "X-Token" => "s3cr3t"}).and_return(response)
      result = described_class.get(request)
      expect(result).to be_success
    end

    it 'wraps exceptions in Failures' do
      expect(::RestClient).to receive(:get).with('https://example.com', { "X-Token" => "s3cr3t"}).and_raise(RestClient::ExceptionWithResponse)
      result = described_class.get(request)
      expect(result).to be_failure
    end
  end

  describe '.post' do
    let(:request) { FriendlyShipping::Request.new(url: 'https://example.com', body: 'body', headers: { "X-Token" => "s3cr3t"}) }
    let(:response) { double(code: 200, body: 'ok', headers: {}) }

    it 'forwards the arguments to RestClient and returns a Success' do
      expect(::RestClient).to receive(:post).with('https://example.com', 'body', { "X-Token" => "s3cr3t"}).and_return(response)
      result = described_class.post(request)
      expect(result).to be_success
    end

    it 'wraps exceptions in Failures' do
      expect(::RestClient).to receive(:post).with('https://example.com', 'body', { "X-Token" => "s3cr3t"}).and_raise(RestClient::ExceptionWithResponse)
      result = described_class.post(request)
      expect(result).to be_failure
    end
  end

  describe '.put' do
    it 'forwards the arguments to RestClient and returns a Success' do
      expect(::RestClient).to receive(:put).with('https://example.com', 'body', { "X-Token" => "s3cr3t"}).and_return(response)
      result = described_class.put('https://example.com', 'body', { "X-Token" => "s3cr3t"})
      expect(result).to be_success
    end

    it 'wraps exceptions in Failures' do
      expect(::RestClient).to receive(:put).with('https://example.com', 'body', { "X-Token" => "s3cr3t"}).and_raise(RestClient::ExceptionWithResponse)
      result = described_class.put('https://example.com', 'body', { "X-Token" => "s3cr3t"})
      expect(result).to be_failure
    end
  end
end
