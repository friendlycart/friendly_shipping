# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Pickup service options for a UPS Freight shipment. Each enabled option is sent as an indicator.
      class LabelPickupOptions
        # @return [Boolean, nil] whether holiday pickup is requested
        attr_reader :holiday_pickup

        # @return [Boolean, nil] whether inside pickup is requested
        attr_reader :inside_pickup

        # @return [Boolean, nil] whether residential pickup is requested
        attr_reader :residential_pickup

        # @return [Boolean, nil] whether weekend pickup is requested
        attr_reader :weekend_pickup

        # @return [Boolean, nil] whether a lift gate is required
        attr_reader :lift_gate_required

        # @return [Boolean, nil] whether limited access pickup is requested
        attr_reader :limited_access_pickup

        # @param holiday_pickup [Boolean, nil] whether holiday pickup is requested
        # @param inside_pickup [Boolean, nil] whether inside pickup is requested
        # @param residential_pickup [Boolean, nil] whether residential pickup is requested
        # @param weekend_pickup [Boolean, nil] whether weekend pickup is requested
        # @param lift_gate_required [Boolean, nil] whether a lift gate is required
        # @param limited_access_pickup [Boolean, nil] whether limited access pickup is requested
        def initialize(
          holiday_pickup: nil,
          inside_pickup: nil,
          residential_pickup: nil,
          weekend_pickup: nil,
          lift_gate_required: nil,
          limited_access_pickup: nil
        )
          @holiday_pickup = holiday_pickup
          @inside_pickup = inside_pickup
          @residential_pickup = residential_pickup
          @weekend_pickup = weekend_pickup
          @lift_gate_required = lift_gate_required
          @limited_access_pickup = limited_access_pickup
        end
      end
    end
  end
end
