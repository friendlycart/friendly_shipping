require 'spec_helper'

RSpec.describe FriendlyShipping::RestClient do
  let(:response) { double }

  describe '.get' do
    it 'forwards the arguments to RestClient and returns a Success' do
      expect(::RestClient).to receive(:get).with('https://example.com', { "X-Token" => "s3cr3t"}).and_return(response)
      result = described_class.get('https://example.com', { "X-Token" => "s3cr3t"})
      expect(result).to be_success
    end

    it 'wraps exceptions in Failures' do
      expect(::RestClient).to receive(:get).with('https://example.com', { "X-Token" => "s3cr3t"}).and_raise(RestClient::ExceptionWithResponse)
      result = described_class.get('https://example.com', { "X-Token" => "s3cr3t"})
      expect(result).to be_failure
    end
  end

  describe '.post' do
    it 'forwards the arguments to RestClient and returns a Success' do
      expect(::RestClient).to receive(:post).with('https://example.com', 'body', { "X-Token" => "s3cr3t"}).and_return(response)
      result = described_class.post('https://example.com', 'body', { "X-Token" => "s3cr3t"})
      expect(result).to be_success
    end


    it 'wraps exceptions in Failures' do
      expect(::RestClient).to receive(:post).with('https://example.com', 'body', { "X-Token" => "s3cr3t"}).and_raise(RestClient::ExceptionWithResponse)
      result = described_class.post('https://example.com', 'body', { "X-Token" => "s3cr3t"})
      expect(result).to be_failure
    end
  end
end
