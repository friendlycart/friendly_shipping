# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Delivery service options for a UPS Freight shipment. Each enabled option is sent as an indicator.
      class LabelDeliveryOptions
        # @return [Boolean, nil] whether to call before delivery
        attr_reader :call_before_delivery

        # @return [Boolean, nil] whether holiday delivery is requested
        attr_reader :holiday_delivery

        # @return [Boolean, nil] whether inside delivery is requested
        attr_reader :inside_delivery

        # @return [Boolean, nil] whether residential delivery is requested
        attr_reader :residential_delivery

        # @return [Boolean, nil] whether weekend delivery is requested
        attr_reader :weekend_delivery

        # @return [Boolean, nil] whether a lift gate is required
        attr_reader :lift_gate_required

        # @return [Boolean, nil] whether limited access delivery is requested
        attr_reader :limited_access_delivery

        # @param call_before_delivery [Boolean, nil] whether to call before delivery
        # @param holiday_delivery [Boolean, nil] whether holiday delivery is requested
        # @param inside_delivery [Boolean, nil] whether inside delivery is requested
        # @param residential_delivery [Boolean, nil] whether residential delivery is requested
        # @param weekend_delivery [Boolean, nil] whether weekend delivery is requested
        # @param lift_gate_required [Boolean, nil] whether a lift gate is required
        # @param limited_access_delivery [Boolean, nil] whether limited access delivery is requested
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
