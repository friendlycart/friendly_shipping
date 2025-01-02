# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::RatesPackageOptions do
  subject(:options) { described_class.new(package_id: "package") }

  it_behaves_like "overrideable item options class" do
    let(:default_class) { FriendlyShipping::Services::ShipEngine::RatesItemOptions }
  end
end
