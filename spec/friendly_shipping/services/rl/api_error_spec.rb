# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::ApiError do
  describe "#message" do
    let(:body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'rl', fixture)) }
    let(:error) { RestClient::Exception.new(double(body: body, code: 400)) }

    subject { described_class.new(error).message }

    context "with API error response" do
      let(:fixture) { "rate_quote/failure.json" }
      it { is_expected.to eq("At least one Item is required") }
    end

    context "with timeout error response" do
      let(:error) { RestClient::Exceptions::ReadTimeout.new("Timed out reading data from server") }
      it { is_expected.to eq("Timed out reading data from server") }
    end
  end
end
