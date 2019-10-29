# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps::ParseXMLResponse do
  let(:response) do
    Nokogiri::XML::Builder.new do |xml|
      xml.Error do
        xml.Number '0'
        xml.source 'WebtoolsAMS'
        xml.Description 'Something went wrong'
      end
    end.to_xml
  end

  subject(:parser) { described_class.call(response, 'RateV4Response') }

  it { is_expected.to be_failure }

  it 'has the correct error message' do
    expect(subject.failure.to_s).to eq('0: Something went wrong')
  end

  context 'with a successful response' do
    let(:response) { File.open(File.join(gem_root, 'spec', 'fixtures', 'usps', 'rates_api_response_regional_single.xml')).read }

    it { is_expected.to be_success }

    it 'contains an XML document with the requested root' do
      expect(subject.value!).to be_a(Nokogiri::XML::Document)
      expect(subject.value!.root.name).to eq('RateV4Response')
    end

    context 'when requesting the wrong root tag' do
      subject(:parser) { described_class.call(response, 'Wat') }

      it { is_expected.to be_failure }
    end
  end

  context 'with invalid XML in response body' do
    let(:response) { 'invalid XML' }

    it { is_expected.to be_failure }

    it 'has the correct error' do
      expect(subject.failure).to be_a(Nokogiri::XML::SyntaxError)
      expect(subject.failure.message).to match(/Start tag expected/)
    end
  end
end
