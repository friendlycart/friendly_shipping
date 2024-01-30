# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::DocumentOptions do
  subject(:options) { described_class.new }

  it "has good defaults" do
    expect(options.type).to eq(:label)
    expect(options.format).to eq(:pdf)
    expect(options.thermal).to be(false)
    expect(options.start_position).to eq(1)
    expect(options.number_of_stickers).to eq(1)
  end

  it "returns expected codes" do
    expect(options.format_code).to eq("01")
    expect(options.document_type_code).to eq("30")
    expect(options.thermal_code).to eq("01")
  end
end
