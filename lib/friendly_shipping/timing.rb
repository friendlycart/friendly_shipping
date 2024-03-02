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
