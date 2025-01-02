# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::LabelDocumentOptions do
  subject { described_class.new }

  it "has good defaults" do
    expect(subject.format_code).to eq("01")
    expect(subject.document_type_code).to eq("30")
    expect(subject.length).to eq("4")
    expect(subject.width).to eq("6")
    expect(subject.thermal_code).to eq("01")
    expect(subject.labels_per_page).to eq("1")
  end
end
