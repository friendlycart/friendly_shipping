require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::ParseVoidResponse do
  subject { described_class.new(response: response).call }
  let(:response) { double(body: response_body) }
  let(:response_body) do
    {
      "approved": true,
      "message": "Request for refund submitted. This label has been voided."
    }.to_json
  end

  context 'for a successful response' do
    it { is_expected.to be_success }

    it 'wraps the message' do
      expect(subject.value!).to eq("Request for refund submitted. This label has been voided.")
    end
  end
end
