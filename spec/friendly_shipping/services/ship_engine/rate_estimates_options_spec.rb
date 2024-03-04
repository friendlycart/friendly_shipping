# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::RateEstimatesOptions do
  subject(:options) { described_class.new(carriers: [double(id: "se-12345")]) }

  it { is_expected.to respond_to(:carriers) }
  it { is_expected.to respond_to(:ship_date) }
  it { is_expected.to be_a(FriendlyShipping::ShipmentOptions) }

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::PackageOptions }
    let(:required_attrs) { { carriers: [] } }
  end
end
