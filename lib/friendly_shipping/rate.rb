# frozen_string_literal: true

module FriendlyShipping
  # Base class for a shipping rate returned by a carrier API.
  class Rate
    # Indicates a shipping rate has no amounts.
    class NoAmountsGiven < StandardError; end

    # @return [ShippingMethod] the rate's shipping method
    attr_reader :shipping_method

    # @return [Hash{String,Symbol=>Money}] the amounts that make up the rate
    attr_reader :amounts

    # @return [Integer] the remote service ID for the rate
    attr_reader :remote_service_id

    # @return [Time] the pickup date for the rate
    attr_reader :pickup_date

    # @return [Time] the delivery date for the rate
    attr_reader :delivery_date

    # @return [Boolean] whether the delivery date is guaranteed
    attr_reader :guaranteed

    # @return [Array] any warnings that were generated while getting this rate
    attr_reader :warnings

    # @return [Array] any errors that were generated while getting this rate
    attr_reader :errors

    # @return [Hash] additional data related to the rate
    attr_reader :data

    # @param shipping_method [ShippingMethod] the rate's shipping method
    # @param amounts [Hash{String,Symbol=>Money}] the amounts that make up the rate
    # @param remote_service_id [Integer] the remote service ID for the rate
    # @param pickup_date [Time] the pickup date for the rate
    # @param delivery_date [Time] the delivery date for the rate
    # @param guaranteed [Boolean] whether the delivery date is guaranteed
    # @param warnings [Array] any warnings that were generated while getting this rate
    # @param errors [Array] any errors that were generated while getting this rate
    # @param data [Hash] additional data related to the rate
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

    # Make this class interchangeable with FriendlyShipping::Timing
    alias_method :pickup, :pickup_date
    alias_method :delivery, :delivery_date

    # Sums all the amounts in the rate, returning the total amount.
    # @return [Money]
    # @raise [NoAmountsGiven] if the rate has no amounts
    def total_amount
      raise NoAmountsGiven if amounts.empty?

      amounts.map { |_name, amount| amount }.sum(Money.new(0, 'USD'))
    end
  end
end
