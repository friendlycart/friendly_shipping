# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::Reconex::Document do
  subject(:document) do
    described_class.new(
      document_type: :bol,
      filename: "NewBillOfLading",
      format: :pdf,
      binary: "decoded-binary-content"
    )
  end

  it "has the correct document_type" do
    expect(document.document_type).to eq(:bol)
  end

  it "has the correct filename" do
    expect(document.filename).to eq("NewBillOfLading")
  end

  it "has the correct format" do
    expect(document.format).to eq(:pdf)
  end

  it "has the correct binary" do
    expect(document.binary).to eq("decoded-binary-content")
  end
end
