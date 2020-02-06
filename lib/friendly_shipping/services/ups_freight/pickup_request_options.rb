# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class PickupRequestOptions
        attr_reader :pickup_time_window,
                    :requester,
                    :third_party_requester,
                    :requester_email,
                    :comments

        def initialize(
          pickup_time_window:,
          requester:,
          requester_email:,
          comments: nil,
          third_party_requester: false
        )
          @pickup_time_window = pickup_time_window
          @requester = requester
          @third_party_requester = third_party_requester
          @requester_email = requester_email
          @comments = comments
        end
      end
    end
  end
end
