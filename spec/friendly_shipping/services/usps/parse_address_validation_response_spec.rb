# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps::ParseAddressValidationResponse do
  let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'usps', 'address_validation_response.xml')) }
  let(:request) { double(debug: false) }
  let(:response) { double(body: response_body) }

  subject { described_class.call(request: request, response: response) }

  context 'with a successful request' do
    it { is_expected.to be_success }

    it 'returns the address with address type' do
      address = subject.value!.data.first
      expect(address).to be_a(Physical::Location)
      expect(address.address1).to eq('205 BAGWELL AVE')
      expect(address.address2).to be nil
      expect(address.city).to eq('NUTTER FORT')
      expect(address.region.name).to eq('West Virginia')
      expect(address.country.name).to eq('United States')
      expect(address.zip).to eq('26301')
      expect(address.address_type).to be nil
    end
  end

  context 'with a no-candidates request' do
    let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'usps', 'address_validation_no_candidates_response.xml')) }

    it { is_expected.to be_failure }

    it 'has the correct error message' do
      expect(subject.failure.to_s).to eq("-2147219401: Address Not Found.")
    end
  end
end
