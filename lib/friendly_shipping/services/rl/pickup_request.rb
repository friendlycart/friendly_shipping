# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      class PickupRequest
        attr_reader :pro_number,
                    :pickup_request_number

        # @param [String] pro_number
        # @param [String] pickup_request_number
        def initialize(
          pro_number:,
          pickup_request_number:
        )
          @pro_number = pro_number
          @pickup_request_number = pickup_request_number
        end

        def valid?
          pro_number.present? && pickup_request_number.present?
        end
      end
    end
  end
end
