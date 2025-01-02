# frozen_string_literal: true

# frozen_string_literal true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::GenerateEmailOptionsHash do
  let(:email_options) do
    FriendlyShipping::Services::UpsFreight::LabelEmailOptions.new(
      email: 'customer@example.com',
      undeliverable_email: 'customer_service@example.com',
      email_type: :ship_notification,
    )
  end

  subject { described_class.call(email_options: email_options) }

  it 'has all the right things' do
    is_expected.to eq(
      EMailInformation: {
        EMail: {
          EMailAddress: "customer@example.com",
          UndeliverableEMailAddress: "customer_service@example.com"
        },
        EMailType: {
          Code: "001"
        }
      }
    )
  end
end
