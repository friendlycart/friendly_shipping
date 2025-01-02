# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsFreight::GeneratePickupRequestHash do
  subject { described_class.call(pickup_request_options: pickup_request_options) }

  let(:pickup_request_options) do
    FriendlyShipping::Services::UpsFreight::PickupRequestOptions.new(
      requester: requester,
      requester_email: 'requester@example.com',
      third_party_requester: true,
      comments: 'Beware of the dog',
      pickup_time_window: Time.new(2019, 12, 9, 17)..Time.new(2019, 12, 9, 19)
    )
  end

  let(:requester) do
    Physical::Location.new(
      name: 'John Doe',
      company_name: 'Acme, Inc',
      phone: '9999999999'
    )
  end

  it do
    is_expected.to eq(
      AdditionalComments: 'Beware of the dog',
      Requester: {
        ThirdPartyRequester: '',
        AttentionName: 'John Doe',
        EMailAddress: 'requester@example.com',
        Name: 'Acme, Inc',
        Phone: {
          Number: '9999999999'
        }
      },
      PickupDate: '20191209',
      EarliestTimeReady: '1700',
      LatestTimeReady: '1900'
    )
  end
end
