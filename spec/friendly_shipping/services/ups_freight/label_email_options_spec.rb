# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ups_freight/label_email_options'

RSpec.describe FriendlyShipping::Services::UpsFreight::LabelEmailOptions do
  subject do
    described_class.new(
      email: "customer@example.com",
      undeliverable_email: "customer_service@example.com",
      email_type: :ship_notification
    )
  end

  it { is_expected.to respond_to(:subject) }
  it { is_expected.to respond_to(:body) }

  it 'stores the given data' do
    expect(subject.email).to eq("customer@example.com")
    expect(subject.undeliverable_email).to eq("customer_service@example.com")
    expect(subject.email_type_code).to eq("001")
  end
end
