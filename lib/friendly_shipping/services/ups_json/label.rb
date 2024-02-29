# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class Label < FriendlyShipping::Label
        attr_reader :usps_tracking_number

        # @param [String] usps_tracking_number The label's usps tracking number. Limited to SUREPOST
        def initialize(
          usps_tracking_number: nil,
          **kwargs
        )
          @usps_tracking_number = usps_tracking_number
          super(**kwargs)
        end
      end
    end
  end
end
