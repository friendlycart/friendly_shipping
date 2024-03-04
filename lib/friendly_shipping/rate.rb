# frozen_string_literal: true

module FriendlyShipping
  class Rate
    class NoAmountsGiven < StandardError; end
    attr_reader :shipping_method,
                :amounts,
                :remote_service_id,
                :pickup_date,
                :delivery_date,
                :guaranteed,
                :warnings,
                :errors,
                :data

    # @param [FriendlyShipping::ShippingMethod] shipping_method The rate's shipping method
    # @param [Hash] amounts The amounts (as Money objects) that make up the rate
    # @param [Integer] remote_service_id The remote service ID for the rate
    # @param [Time] pickup_date The pickup date for the rate
    # @param [Time] delivery_date The delivery date for the rate
    # @param [Boolean] guaranteed Whether the delivery date is guaranteed
    # @param [Array] warnings Any warnings that were generated
    # @param [Array] errors Any errors that were generated
    # @param [Hash] data Additional data related to the rate
    def initialize(
      shipping_method:,
      amounts:,
      remote_service_id: nil,
      pickup_date: nil,
      delivery_date: nil,
      guaranteed: false,
      warnings: [],
      errors: [],
      data: {}
    )
      @remote_service_id = remote_service_id
      @shipping_method = shipping_method
      @amounts = amounts
      @pickup_date = pickup_date
      @delivery_date = delivery_date
      @guaranteed = guaranteed
      @warnings = warnings
      @errors = errors
      @data = data
    end

    alias_method :pickup, :pickup_date
    alias_method :delivery, :delivery_date

    def total_amount
      raise NoAmountsGiven if amounts.empty?

      amounts.map { |_name, amount| amount }.sum(Money.new(0, 'USD'))
    end
  end
end
