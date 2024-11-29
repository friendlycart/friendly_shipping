# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps::ParseXMLResponse do
  let(:body) do
    Nokogiri::XML::Builder.new do |xml|
      xml.Error do
        xml.Number '0'
        xml.source 'WebtoolsAMS'
        xml.Description 'Something went wrong'
      end
    end.to_xml
  end

  let(:request) { FriendlyShipping::Request.new(url: nil, debug: true) }
  let(:response) { FriendlyShipping::Response.new(status: nil, body: body, headers: nil) }

  subject(:parser) do
    described_class.call(
      request: request,
      response: response,
      expected_root_tag: 'RateV4Response'
    )
  end

  it { is_expected.to be_failure }

  it 'has the correct error message' do
    expect(subject.failure).to be_a(FriendlyShipping::ApiResult)
    expect(subject.failure.data).to eq('0: Something went wrong')
    expect(subject.failure.original_request).to eq(request)
    expect(subject.failure.original_response).to eq(response)
  end

  context 'with a successful response' do
    let(:body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'usps', 'rates_api_response_regional_single.xml')) }

    it { is_expected.to be_success }

    it 'contains an XML document with the requested root' do
      expect(subject.value!).to be_a(Nokogiri::XML::Document)
      expect(subject.value!.root.name).to eq('RateV4Response')
    end

    context 'when requesting the wrong root tag' do
      subject(:parser) do
        described_class.call(
          request: request,
          response: response,
          expected_root_tag: 'Wat'
        )
      end

      it { is_expected.to be_failure }

      it 'has the correct error message' do
        expect(subject.failure).to be_a(FriendlyShipping::ApiResult)
        expect(subject.failure.data).to eq('Invalid document')
        expect(subject.failure.original_request).to eq(request)
        expect(subject.failure.original_response).to eq(response)
      end
    end
  end

  context 'with invalid XML in response body' do
    let(:body) { 'invalid XML' }

    it { is_expected.to be_failure }

    it 'has the correct error' do
      expect(subject.failure).to be_a(FriendlyShipping::ApiResult)
      expect(subject.failure.data).to be_a(Nokogiri::XML::SyntaxError)
      expect(subject.failure.data.message).to match(/Start tag expected/)
    end
  end
end
