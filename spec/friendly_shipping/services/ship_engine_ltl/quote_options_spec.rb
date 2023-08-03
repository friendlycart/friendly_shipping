# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ship_engine_ltl/quote_options'

RSpec.describe FriendlyShipping::Services::ShipEngineLTL::QuoteOptions do
  subject(:options) { described_class.new }

  [
    :service_code,
    :pickup_date,
    :accessorial_service_codes,
    :packages_serializer_class
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end
end
