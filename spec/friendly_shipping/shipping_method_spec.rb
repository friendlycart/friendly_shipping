# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::ShippingMethod do
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:service_code) }
  it { is_expected.to respond_to(:carrier) }
  it { is_expected.to respond_to(:origin_countries) }
  it { is_expected.to respond_to(:domestic?) }
  it { is_expected.to respond_to(:international?) }
  it { is_expected.to respond_to(:multi_package?) }
end
