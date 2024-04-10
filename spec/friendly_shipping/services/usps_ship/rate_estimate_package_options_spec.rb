# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip::RateEstimatePackageOptions do
  subject(:options) { described_class.new(package_id: "package") }

  it_behaves_like "overrideable item options class" do
    let(:default_class) { FriendlyShipping::ItemOptions }
  end

  it "sets reasonable defaults" do
    expect(options.processing_category).to eq("MACHINABLE")
    expect(options.rate_indicator).to eq("DR")
    expect(options.price_type).to eq("RETAIL")
  end
end
