# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Response do
  let(:status) { 200 }
  let(:body) { "Hello!" }
  let(:headers) { { "X-Header" => "Nice" } }

  subject(:response) { described_class.new(status: status, body: body, headers: headers) }

  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:body) }
  it { is_expected.to respond_to(:headers) }

  describe ".new_from_rest_client_response" do
    subject(:new_from_rest_client_response) do
      described_class.new_from_rest_client_response(rest_client_response)
    end

    let(:rest_client_response) do
      instance_double(
        RestClient::Response,
        code: status,
        body: body,
        headers: headers
      )
    end

    it { is_expected.to eq(described_class.new(status: status, body: body, headers: headers)) }

    context "with nil response" do
      let(:rest_client_response) { nil }
      it { is_expected.to eq(described_class.new(status: nil, body: nil, headers: {})) }
    end
  end

  describe "#==" do
    subject(:equality) { response == other }

    context "when attributes match" do
      let(:other) { response }
      it { is_expected.to be(true) }
    end

    context "when attributes do not match" do
      let(:other) { described_class.new(status: 404, body: "File Not Found", headers: {}) }
      it { is_expected.to be(false) }
    end

    context "when class does not match" do
      let(:other) { String.new }
      it { is_expected.to be(false) }
    end
  end

  it { is_expected.to respond_to(:eql?) }

  describe "#hash" do
    subject(:hash) { response.hash }
    it { is_expected.to eq([status, body, headers].hash) }
  end
end
