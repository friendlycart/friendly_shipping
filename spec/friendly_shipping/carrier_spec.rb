require 'spec_helper'

RSpec.describe FriendlyShipping::Carrier do
  it { is_expected.to respond_to :id }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :services }
  it { is_expected.to respond_to :balance }
end
