# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::BadRequest do
  let(:original_exception) { double(to_s: '400 Bad Request', response: double(body: response_body)) }
  let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ship_engine', 'invalid_package_code.json')) }

  describe 'to_s' do
    subject { described_class.new(original_exception).to_s }

    it { is_expected.to eq("invalid package_code 'not_a_usps_package_code'") }

    context 'if the response body is invalid JSON' do
      let(:response_body) { '' }

      it { is_expected.to eq("400 Bad Request") }
    end

    context 'if the response body does not have the expect errors array' do
      let(:response_body) { { errors: nil }.to_json }

      it { is_expected.to eq("400 Bad Request") }
    end
  end
end
