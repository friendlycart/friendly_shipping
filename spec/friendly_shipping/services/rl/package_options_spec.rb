# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::PackageOptions do
  subject(:options) { described_class.new(package_id: "package") }

  [
    :freight_class,
    :nmfc_primary_code,
    :nmfc_sub_code
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  it_behaves_like "overrideable item options class" do
    let(:default_class) { FriendlyShipping::Services::RL::ItemOptions }
  end
end
