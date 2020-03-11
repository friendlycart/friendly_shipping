# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GeneratePickupOptionsHash
        def self.call(pickup_options:)
          {
            PickupOptions: {
              LiftGateRequiredIndicator: pickup_options.lift_gate_required ? "" : nil,
              WeekendPickupIndicator: pickup_options.weekend_pickup ? "" : nil,
              InsidePickupIndicator: pickup_options.inside_pickup ? "" : nil,
              HolidayPickupIndicator: pickup_options.holiday_pickup ? "" : nil,
              LimitedAccessPickupIndicator: pickup_options.limited_access_pickup ? "" : nil
            }.compact.presence
          }.compact.presence
        end
      end
    end
  end
end
