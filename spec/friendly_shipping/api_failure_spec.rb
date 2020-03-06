# frozen_string_literal: true

RSpec.describe FriendlyShipping::ApiFailure do
  let(:data) { :failure }
  let(:original_request) { double(debug: debug) }
  let(:original_response) { :original_response }
  let(:debug) { false }

  subject { described_class.new(data, original_request: original_request, original_response: original_response) }

  it 'aliases #failure to #data' do
    expect(subject.failure).to eq(:failure)
  end

  it 'stores the data but no debugging info' do
    expect(subject.data).to eq(:failure)
    expect(subject.original_request).to be nil
    expect(subject.original_response).to be nil
  end

  it 'serializes the data when to_s is called' do
    expect(subject.to_s).to eq("failure")
  end

  context 'with debug set to true' do
    let(:debug) { true }

    it 'stores the data with debugging info' do
      expect(subject.data).to eq(:failure)
      expect(subject.original_request).to eq(original_request)
      expect(subject.original_response).to eq(original_response)
    end
  end
end
