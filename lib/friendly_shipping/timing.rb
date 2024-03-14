# frozen_string_literal: true

module FriendlyShipping
  # Base class for a transit timing estimate returned by a carrier API.
  class Timing
    # @return [ShippingMethod] this timing's shipping method
    attr_reader :shipping_method

    # @return [Time] the pickup estimate
    attr_reader :pickup

    # @return [Time] the delivery estimate
    attr_reader :delivery

    # @return [Boolean] whether the delivery estimate is guaranteed
    attr_reader :guaranteed

    # @return [Array] any warnings that were generated
    attr_reader :warnings

    # @return [Array] any errors that were generated
    attr_reader :errors

    # @return [Hash] additional data related to the timing (DEPRECATED: use `data` instead)
    attr_reader :properties

    # @return [Hash] additional data related to the timing
    attr_reader :data

    # @param shipping_method [ShippingMethod] this timing's shipping method
    # @param pickup [Time] the pickup estimate
    # @param delivery [Time] the delivery estimate
    # @param guaranteed [Boolean] whether the delivery estimate is guaranteed
    # @param warnings [Array] any warnings that were generated
    # @param errors [Array] any errors that were generated
    # @param properties [Hash] additional data related to the timing
    # @param data [Hash] additional data related to the timing (DEPRECATED: use `data` instead)
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

    # Calculates and returns the time between pickup and delivery.
    # @return [Time]
    def time_in_transit
      delivery - pickup
    end
  end
end
