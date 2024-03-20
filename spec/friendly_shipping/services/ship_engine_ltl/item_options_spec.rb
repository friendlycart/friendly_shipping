# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngineLTL::ItemOptions do
  subject(:options) { described_class.new(item_id: "123") }

  [
    :packaging_code,
    :freight_class,
    :nmfc_code,
    :stackable,
    :hazardous_materials
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end
end
