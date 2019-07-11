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

  subject(:parser) { described_class.call(response, 'SomeTag') }

  it { is_expected.to be_failure }

  it 'has the correct error message' do
    expect(subject.failure.to_s).to eq('0: Something went wrong')
  end
end
