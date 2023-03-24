# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ship_engine/label_customs_options'

RSpec.describe FriendlyShipping::Services::ShipEngine::LabelCustomsOptions do
  subject(:options) { described_class.new }

  [
    :contents,
    :non_delivery
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  context "contents" do
    subject(:contents) { options.contents }
    it { is_expected.to eq("merchandise") }
  end

  context "non_delivery" do
    subject(:contents) { options.non_delivery }
    it { is_expected.to eq("return_to_sender") }
  end
end
