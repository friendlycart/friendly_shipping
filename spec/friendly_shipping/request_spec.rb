require 'spec_helper'

RSpec.describe FriendlyShipping::Request do
  let(:url) { 'https://www.example.com/labels' }
  let(:body) { "Hello!" }
  let(:headers) { { "X-Header" => "Nice"} }

  subject { described_class.new(url: url, body: body, headers: headers) }

  it { is_expected.to respond_to(:url) }
  it { is_expected.to respond_to(:body) }
  it { is_expected.to respond_to(:headers) }
end
