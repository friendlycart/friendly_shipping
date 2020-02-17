# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Request do
  let(:url) { 'https://www.example.com/labels' }
  let(:body) { "Hello!" }
  let(:readable_body) { "World" }
  let(:headers) { { "X-Header" => "Nice" } }

  subject do
    described_class.new(
      url: url,
      body: body,
      readable_body: readable_body,
      headers: headers
    )
  end

  it { is_expected.to respond_to(:url) }
  it { is_expected.to respond_to(:body) }
  it { is_expected.to respond_to(:headers) }
  it { is_expected.to respond_to(:open_timeout) }
  it { is_expected.to respond_to(:read_timeout) }
  it { is_expected.to respond_to(:debug) }

  describe '#readable_body' do
    it 'returns readable body' do
      expect(subject.readable_body).to eq('World')
    end

    context 'with blank readable body' do
      let(:readable_body) { '' }

      it 'returns body' do
        expect(subject.readable_body).to eq('Hello!')
      end
    end
  end
end
