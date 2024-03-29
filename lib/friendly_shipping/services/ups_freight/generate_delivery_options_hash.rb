# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GenerateDeliveryOptionsHash
        def self.call(delivery_options:)
          {
            DeliveryOptions: {
              CallBeforeDeliveryIndicator: delivery_options.call_before_delivery ? "" : nil,
              HolidayDeliveryIndicator: delivery_options.holiday_delivery ? "" : nil,
              InsideDeliveryIndicator: delivery_options.inside_delivery ? "" : nil,
              ResidentialDeliveryIndicator: delivery_options.residential_delivery ? "" : nil,
              WeekendDeliveryIndicator: delivery_options.weekend_delivery ? "" : nil,
              LiftGateRequiredIndicator: delivery_options.lift_gate_required ? "" : nil,
              LimitedAccessDeliveryIndicator: delivery_options.limited_access_delivery ? "" : nil
            }.compact.presence
          }.compact.presence
        end
      end
    end
  end
end
