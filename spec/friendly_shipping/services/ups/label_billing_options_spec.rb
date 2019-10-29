# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups/label_billing_options'

RSpec.describe FriendlyShipping::Services::Ups::LabelBillingOptions do
  subject { described_class.new }

  [
    :bill_third_party,
    :bill_to_consignee,
    :prepay,
    :billing_account,
    :billing_zip,
    :billing_country,
    :currency,
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end
end
