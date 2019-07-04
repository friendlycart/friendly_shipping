# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Carrier do
  it { is_expected.to respond_to :id }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :shipping_methods }
  it { is_expected.to respond_to :balance }
  it { is_expected.to respond_to :data }
end
