# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::StructureOptions do
  subject(:options) { described_class.new(structure_id: "structure") }

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::Services::TForceFreight::RatesPackageOptions }
    let(:required_attrs) { { structure_id: "structure" } }
  end
end
