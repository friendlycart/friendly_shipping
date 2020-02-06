# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class LabelPickupOptions
        attr_reader :holiday_pickup,
                    :inside_pickup,
                    :weekend_pickup,
                    :lift_gate_required,
                    :limited_access_pickup

        def initialize(
          holiday_pickup: nil,
          inside_pickup: nil,
          weekend_pickup: nil,
          lift_gate_required: nil,
          limited_access_pickup: nil
        )
          @holiday_pickup = holiday_pickup
          @inside_pickup = inside_pickup
          @weekend_pickup = weekend_pickup
          @lift_gate_required = lift_gate_required
          @limited_access_pickup = limited_access_pickup
        end
      end
    end
  end
end
