# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GeneratePickupRequestHash
        class << self
          def call(pickup_request_options:)
            return unless pickup_request_options

            {
              AdditionalComments: pickup_request_options.comments,
              Requester: {
                ThirdPartyRequester: pickup_request_options.third_party_requester ? '' : nil,
                AttentionName: pickup_request_options.requester.name,
                EMailAddress: pickup_request_options.requester_email,
                Name: pickup_request_options.requester.company_name,
                Phone: {
                  Number: pickup_request_options.requester.phone
                }.compact
              }.compact,
              PickupDate: pickup_request_options.pickup_time_window.begin.strftime('%Y%m%d'),
              EarliestTimeReady: pickup_request_options.pickup_time_window.begin.strftime('%H%M'),
              LatestTimeReady: pickup_request_options.pickup_time_window.end.strftime('%H%M'),
            }.compact
          end
        end
      end
    end
  end
end
