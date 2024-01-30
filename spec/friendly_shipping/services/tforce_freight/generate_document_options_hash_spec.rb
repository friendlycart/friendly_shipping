# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::GenerateDocumentOptionsHash do
  subject(:call) do
    described_class.call(document_options: document_options)
  end

  let(:document_options) do
    FriendlyShipping::Services::TForceFreight::DocumentOptions.new
  end

  it "has all the right things" do
    is_expected.to eq(
      {
        type: "30",
        format: "01",
        label: {
          type: "01",
          startPosition: 1,
          numberOfStickers: 1
        }
      }
    )
  end
end
