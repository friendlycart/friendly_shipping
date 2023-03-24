# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ship_engine/label_options'
require 'friendly_shipping/services/ship_engine/label_customs_options'

RSpec.describe FriendlyShipping::Services::ShipEngine::LabelOptions do
  subject(:options) { described_class.new(shipping_method: double) }

  [
    :shipping_method,
    :label_format,
    :label_download_type,
    :label_image_id,
    :customs_options
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  context "customs_options" do
    subject(:customs_options) { options.customs_options }
    it { is_expected.to be_a(FriendlyShipping::Services::ShipEngine::LabelCustomsOptions) }
  end
end
