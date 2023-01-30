# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class Label < FriendlyShipping::Label
        attr_reader :usps_tracking_number

        # @param [String] usps_tracking_number The label's usps tracking number. Limited to SUREPOST
        def initialize(
          usps_tracking_number: nil,
          **params
        )
          @usps_tracking_number = usps_tracking_number
          super(**params)
        end
      end
    end
  end
end
