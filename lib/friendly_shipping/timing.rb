# frozen_string_literal: true

module FriendlyShipping
  class Timing
    attr_reader :shipping_method,
                :pickup,
                :delivery,
                :guaranteed,
                :warnings,
                :errors,
                :properties

    def initialize(
      shipping_method:,
      pickup:,
      delivery:,
      guaranteed: false,
      warnings: [],
      errors: [],
      properties: {}
    )
      @shipping_method = shipping_method
      @pickup = pickup
      @delivery = delivery
      @guaranteed = guaranteed
      @warnings = warnings
      @errors = errors
      @properties = properties
    end

    def time_in_transit
      delivery - pickup
    end
  end
end
