# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::ZipCodeLookupResult do
  let(:original_location) { FactoryBot.build(:physical_location) }
  let(:result_location) { FactoryBot.build(:physical_location) }
  let(:request) { double }
  let(:response) { double }

  subject do
    described_class.new(
      original_location: original_location,
      location: result_location,
      original_request: request,
      original_response: response
    )
  end

  it 'has all the right data' do
    expect(subject.original_location).to eq(original_location)
    expect(subject.location).to eq(result_location)
    expect(subject.original_request).to eq(request)
    expect(subject.original_response).to eq(response)
  end
end
