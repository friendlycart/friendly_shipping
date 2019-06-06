require 'spec_helper'

RSpec.describe FriendlyShipping::Response do
  let(:status) { 200 }
  let(:body) { "Hello!" }
  let(:headers) { { "X-Header" => "Nice"} }

  subject { described_class.new(status: status, body: body, headers: headers) }

  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:body) }
  it { is_expected.to respond_to(:headers) }
end
