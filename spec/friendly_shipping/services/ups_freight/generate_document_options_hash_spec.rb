# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::GenerateDocumentOptionsHash do
  let(:document_options) { FriendlyShipping::Services::UpsFreight::LabelDocumentOptions.new }

  subject { JSON.parse(described_class.call(document_options: document_options).to_json) }

  it 'has all the right things' do
    is_expected.to eq(
      "Type" => {
        "Code" => "30"
      },
      "LabelsPerPage" => "1",
      "Format" => {
        "Code" => "01"
      },
      "PrintFormat" => {
        "Code" => "01",
      },
      "PrintSize" => {
        "Length" => "4",
        "Width" => "6"
      }
    )
  end
end
