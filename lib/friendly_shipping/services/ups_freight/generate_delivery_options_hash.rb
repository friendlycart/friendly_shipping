# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GenerateDeliveryOptionsHash
        def self.call(delivery_options:)
          {
            DeliveryOptions: {
              LiftGateRequiredIndicator: delivery_options.lift_gate_required ? "" : nil,
              WeekendPickupIndicator: delivery_options.weekend_delivery ? "" : nil,
              InsidePickupIndicator: delivery_options.inside_delivery ? "" : nil,
              HolidayPickupIndicator: delivery_options.holiday_delivery ? "" : nil,
              LimitedAccessPickupIndicator: delivery_options.limited_access_delivery ? "" : nil
            }.compact.presence
          }.compact.presence
        end
      end
    end
  end
end
