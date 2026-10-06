# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Options for requesting a pickup together with a UPS Freight rate or ship request.
      class PickupRequestOptions
        # @return [Range<Time>] the time window in which the shipment is ready for pickup
        attr_reader :pickup_time_window

        # @return [Physical::Location] the person or company requesting the pickup
        attr_reader :requester

        # @return [Boolean] whether the requester is a third party
        attr_reader :third_party_requester

        # @return [String] the requester's email address
        attr_reader :requester_email

        # @return [String, nil] additional comments for the pickup
        attr_reader :comments

        # @param pickup_time_window [Range<Time>] the time window in which the shipment is ready for pickup
        # @param requester [Physical::Location] the person or company requesting the pickup
        # @param requester_email [String] the requester's email address
        # @param comments [String, nil] additional comments for the pickup
        # @param third_party_requester [Boolean] whether the requester is a third party
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
