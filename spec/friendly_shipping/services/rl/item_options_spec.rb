# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::ItemOptions do
  subject(:options) { described_class.new(item_id: "123") }

  [
    :freight_class,
    :nmfc_primary_code,
    :nmfc_sub_code
  ].each do |attr|
    it { is_expected.to respond_to(attr) }
  end
end
