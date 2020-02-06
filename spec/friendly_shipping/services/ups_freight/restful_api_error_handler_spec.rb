# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/restful_api_error_handler'

RSpec.describe FriendlyShipping::Services::UpsFreight::RestfulApiErrorHandler do
  subject { described_class.call(error) }

  let(:error) { RestClient::BadRequest.new }
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ups_freight', 'failure_with_multiple_errors.json')).read }

  before do
    allow(error).to receive_message_chain(:response, :body) { response_body }
  end

  it { is_expected.to be_failure }

  it 'contains the correct string' do
    expect(subject.failure).to eq("9360721: Missing or Invalid Attention name in the request.\n9370701: Invalid processing option.")
  end
end
