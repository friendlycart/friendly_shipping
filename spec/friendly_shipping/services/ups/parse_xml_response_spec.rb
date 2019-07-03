# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::ParseXMLResponse do
  let(:response) do
    Nokogiri::XML::Builder.new do |xml|
      xml.ResponseRoot do
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

  subject(:parser) { described_class.(response, 'SomeTag') }

  it { is_expected.to be_failure }

  it 'has the correct error message' do
    expect(subject.failure.to_s).to eq('Failure: Something went wrong')
  end
end
