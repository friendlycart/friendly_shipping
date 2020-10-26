# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::ShippingMethod do
  [
    :name,
    :service_code,
    :carrier,
    :origin_countries,
    :data,
    :domestic?,
    :international?,
    :multi_package?,
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end
end
