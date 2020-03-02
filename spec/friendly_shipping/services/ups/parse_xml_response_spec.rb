# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::ParseXMLResponse do
  let(:response) do
    Nokogiri::XML::Builder.new do |xml|
      xml.RatingServiceSelectionResponse do
        xml.Response do
          xml.ResponseStatusCode '0'
          xml.ResponseStatusDescription 'Failure'
          xml.Error do
            xml.ErrorSeverity 'Hard'
            xml.ErrorCode '20007'
            xml.ErrorDescription 'Something went wrong'
          end
        end
      end
    end.to_xml
  end

  subject(:parser) { described_class.call(response, 'RatingServiceSelectionResponse') }

  it { is_expected.to be_failure }

  it 'has the correct error message' do
    expect(subject.failure.to_s).to eq('Failure: Something went wrong')
  end

  context 'with a successful response' do
    let(:response) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ups', 'ups_rates_api_response.xml')).read }

    it { is_expected.to be_success }

    it 'contains an XML document with the requested root' do
      expect(subject.value!).to be_a(Nokogiri::XML::Document)
      expect(subject.value!.root.name).to eq('RatingServiceSelectionResponse')
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
