# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::ParseAddressClassificationResponse do
  let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ups', 'address_validation_response.xml')) }
  let(:request) { double(debug: false) }
  let(:response) { double(body: response_body) }

  subject { described_class.call(request: request, response: response) }

  context 'with a successful request' do
    it { is_expected.to be_success }

    it 'returns the address type' do
      address_type = subject.value!.data
      expect(address_type).to eq('commercial')
    end
  end

  context 'with a no-candidates request' do
    let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ups', 'address_validation_no_candidates_response.xml')) }

    it { is_expected.to be_success }

    it 'returns unknown address type' do
      address_type = subject.value!.data
      expect(address_type).to eq('unknown')
    end
  end

  context 'with an ambiguous address request' do
    let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ups', 'address_validation_ambiguous_address_response.xml')) }

    it { is_expected.to be_success }

    it 'returns the address type' do
      address_type = subject.value!.data
      expect(address_type).to eq('commercial')
    end
  end
end
