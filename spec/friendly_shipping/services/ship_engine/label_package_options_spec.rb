# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ship_engine/label_package_options'

RSpec.describe FriendlyShipping::Services::ShipEngine::LabelPackageOptions do
  subject(:options) { described_class.new(package_id: "package") }

  [
    :package_code,
    :messages
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  it_behaves_like "overrideable item options class" do
    let(:default_class) { FriendlyShipping::Services::ShipEngine::LabelItemOptions }
  end
end
