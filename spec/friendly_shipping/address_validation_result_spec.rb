# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::AddressValidationResult do
  let(:original_address) { FactoryBot.build(:physical_location) }
  let(:suggested_address) { FactoryBot.build(:physical_location) }
  let(:alternative_addresses) { FactoryBot.build_list(:physical_location, 3) }
  let(:request) { double }
  let(:response) { double }

  subject do
    described_class.new(
      original_address: original_address,
      suggestions: [suggested_address, alternative_addresses],
      original_request: request,
      original_response: response
    )
  end

  it 'has all the right data' do
    expect(subject.original_address).to eq(original_address)
    expect(subject.suggestions).to eq([suggested_address, alternative_addresses])
    expect(subject.original_request).to eq(request)
    expect(subject.original_response).to eq(response)
  end
end
