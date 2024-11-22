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

  describe "#initialize" do
    context "with no cause or message" do
      it "raises an ArgumentError" do
        expect { described_class.new(nil) }.to raise_error(ArgumentError)
      end
    end

    context "with cause but no message" do
      subject { described_class.new(error).message }

      it { is_expected.to eq("oops") }
    end

    context "with message but no cause" do
      subject { described_class.new(nil, "yikes").message }

      it { is_expected.to eq("yikes") }
    end
  end
end
