# frozen_string_literal: true

RSpec.describe FriendlyShipping::ApiResult do
  let(:data) { :data }
  let(:original_request) { double(debug: debug) }
  let(:original_response) { :original_response }
  let(:debug) { false }

  subject { described_class.new(data, original_request: original_request, original_response: original_response) }

  it 'stores the data but no debugging info' do
    expect(subject.data).to eq(:data)
    expect(subject.original_request).to be nil
    expect(subject.original_response).to be nil
  end

  context 'with debug set to true' do
    let(:debug) { true }

    it 'stores the data with debugging info' do
      expect(subject.data).to eq(:data)
      expect(subject.original_request).to eq(original_request)
      expect(subject.original_response).to eq(original_response)
    end
  end
end
