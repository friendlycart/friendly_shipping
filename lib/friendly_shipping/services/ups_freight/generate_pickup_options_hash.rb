# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Generates the PickupOptions hash of the ShipmentServiceOptions for UPS Freight ship requests.
      class GeneratePickupOptionsHash
        # @param pickup_options [LabelPickupOptions] the pickup options
        # @return [Hash, nil] the hash with an indicator for each enabled option, or nil if none are enabled
        def self.call(pickup_options:)
          {
            PickupOptions: {
              HolidayPickupIndicator: pickup_options.holiday_pickup ? "" : nil,
              InsidePickupIndicator: pickup_options.inside_pickup ? "" : nil,
              ResidentialPickupIndicator: pickup_options.residential_pickup ? "" : nil,
              WeekendPickupIndicator: pickup_options.weekend_pickup ? "" : nil,
              LiftGateRequiredIndicator: pickup_options.lift_gate_required ? "" : nil,
              LimitedAccessPickupIndicator: pickup_options.limited_access_pickup ? "" : nil
            }.compact.presence
          }.compact.presence
        end
      end
    end
  end
end
