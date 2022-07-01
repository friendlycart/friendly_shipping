# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::ApiError do
  let(:error) { StandardError.new("oops") }

  describe "#cause" do
    subject { described_class.new(error).cause }
    it { is_expected.to eq(error) }
  end

  describe "#message" do
    subject { described_class.new(error, "yikes").message }
    it { is_expected.to eq("yikes") }

    context "with no message provided" do
      subject { described_class.new(error).message }
      it { is_expected.to eq("oops") }
    end
  end
end
