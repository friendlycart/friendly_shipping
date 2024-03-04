# frozen_string_literal: true

module FriendlyShipping
  class Timing
    attr_reader :shipping_method,
                :pickup,
                :delivery,
                :guaranteed,
                :warnings,
                :errors,
                :properties,
                :data

    # @param [FriendlyShipping::ShippingMethod] shipping_method The timing's shipping method
    # @param [Time] pickup The pickup date for the timing
    # @param [Time] delivery The delivery date for the timing
    # @param [Boolean] guaranteed Whether the delivery date is guaranteed
    # @param [Array] warnings Any warnings that were generated
    # @param [Array] errors Any errors that were generated
    # @param [Hash] properties Additional properties related to the timing (DEPRECATED: use `data` instead)
    # @param [Hash] data Additional data related to the timing
    def initialize(
      shipping_method:,
      pickup:,
      delivery:,
      guaranteed: false,
      warnings: [],
      errors: [],
      properties: {},
      data: {}
    )
      @shipping_method = shipping_method
      @pickup = pickup
      @delivery = delivery
      @guaranteed = guaranteed
      @warnings = warnings
      @errors = errors
      @data = @properties = properties.presence || data
      warn "[DEPRECATION] `properties` is deprecated.  Please use `data` instead." if properties.present?
    end

    def time_in_transit
      delivery - pickup
    end
  end
end
