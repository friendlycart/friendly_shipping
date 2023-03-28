# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ship_engine/label_item_options'

RSpec.describe FriendlyShipping::Services::ShipEngine::LabelItemOptions do
  subject(:options) { described_class.new(item_id: "123") }

  [
    :item_id,
    :commodity_code,
    :country_of_origin
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end
end
