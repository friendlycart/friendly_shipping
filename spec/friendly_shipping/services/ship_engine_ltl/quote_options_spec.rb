# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngineLTL::QuoteOptions do
  subject(:options) { described_class.new }

  [
    :service_code,
    :pickup_date,
    :accessorial_service_codes,
    :structures_serializer_class,
    :packages_serializer_class
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::Services::ShipEngineLTL::PackageOptions }
    let(:required_attrs) { {} }
  end
end
