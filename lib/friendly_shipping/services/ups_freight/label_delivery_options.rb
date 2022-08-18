# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class LabelDeliveryOptions
        attr_reader :call_before_delivery,
                    :holiday_delivery,
                    :inside_delivery,
                    :residential_delivery,
                    :weekend_delivery,
                    :lift_gate_required,
                    :limited_access_delivery

        def initialize(
          call_before_delivery: nil,
          holiday_delivery: nil,
          inside_delivery: nil,
          residential_delivery: nil,
          weekend_delivery: nil,
          lift_gate_required: nil,
          limited_access_delivery: nil
        )
          @call_before_delivery = call_before_delivery
          @holiday_delivery = holiday_delivery
          @inside_delivery = inside_delivery
          @residential_delivery = residential_delivery
          @weekend_delivery = weekend_delivery
          @lift_gate_required = lift_gate_required
          @limited_access_delivery = limited_access_delivery
        end
      end
    end
  end
end
