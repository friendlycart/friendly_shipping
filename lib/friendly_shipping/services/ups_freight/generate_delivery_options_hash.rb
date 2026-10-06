# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Generates the DeliveryOptions hash of the ShipmentServiceOptions for UPS Freight ship requests.
      class GenerateDeliveryOptionsHash
        # @param delivery_options [LabelDeliveryOptions] the delivery options
        # @return [Hash, nil] the hash with an indicator for each enabled option, or nil if none are enabled
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
