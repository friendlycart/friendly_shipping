# frozen_string_literal: true

RSpec.describe FriendlyShipping::ApiFailure do
  let(:failure) { :failure }
  let(:original_request) { double(debug: debug) }
  let(:original_response) { :original_response }
  let(:debug) { false }

  subject { described_class.new(failure, original_request: original_request, original_response: original_response) }

  it 'stores the failure but no debugging info' do
    expect(subject.failure).to eq(:failure)
    expect(subject.original_request).to be nil
    expect(subject.original_response).to be nil
  end

  it 'serializes the failure when to_s is called' do
    expect(subject.to_s).to eq("failure")
  end

  context 'with debug set to true' do
    let(:debug) { true }

    it 'stores the failure with debugging info' do
      expect(subject.failure).to eq(:failure)
      expect(subject.original_request).to eq(original_request)
      expect(subject.original_response).to eq(original_response)
    end
  end
end
