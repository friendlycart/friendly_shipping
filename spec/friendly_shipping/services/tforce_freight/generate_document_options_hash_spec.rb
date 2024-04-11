# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::GenerateDocumentOptionsHash do
  subject(:call) do
    described_class.call(document_options: document_options)
  end

  let(:document_options) do
    FriendlyShipping::Services::TForceFreight::DocumentOptions.new
  end

  it do
    is_expected.to eq(
      {
        type: "30",
        format: "01",
        label: {
          type: "07",
          startPosition: 1,
          numberOfStickers: 1
        }
      }
    )
  end

  context "when document type is BOL" do
    let(:document_options) do
      FriendlyShipping::Services::TForceFreight::DocumentOptions.new(
        type: :tforce_bol
      )
    end

    it do
      is_expected.to eq(
        {
          type: "20",
          format: "01"
        }
      )
    end
  end
end
