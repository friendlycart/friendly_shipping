# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/item_options'

RSpec.describe FriendlyShipping::ItemOptions do
  subject { described_class.new(item_id: 'my_item_id') }

  it { is_expected.to respond_to(:item_id) }
end
