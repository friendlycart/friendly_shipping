# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ship_engine/label_options'

RSpec.describe FriendlyShipping::Services::ShipEngine::LabelOptions do
  subject(:options) { described_class.new(shipping_method: double) }

  [
    :shipping_method,
    :label_format,
    :label_download_type,
    :label_image_id
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end
end
