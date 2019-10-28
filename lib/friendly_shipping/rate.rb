# frozen_string_literal: true

module FriendlyShipping
  class Rate
    class NoAmountsGiven < StandardError; end
    attr_reader :shipping_method,
                :amounts,
                :remote_service_id,
                :delivery_date,
                :warnings,
                :errors,
                :data,
                :original_request,
                :original_response

    # @param [FriendlyShipping::ShippingMethod] shipping_method The rate's shipping method
    # @param [Hash] amounts The amounts (as Money objects) that make up the rate
    # @param [Integer] remote_service_id The remote service ID for the rate
    # @param [Time] delivery_date The delivery date for the rate
    # @param [Array] warnings Any warnings that were generated
    # @param [Array] errors Any errors that were generated
    # @param [Hash] data Additional data related to the rate
    # @param [FriendlyShipping::Request] original_request The HTTP request used to obtain the rate
    # @param [FriendlyShipping::Response] original_response The HTTP response for the rate
    def initialize(
      shipping_method:,
      amounts:,
      remote_service_id: nil,
      delivery_date: nil,
      warnings: [],
      errors: [],
      data: {},
      original_request: nil,
      original_response: nil
    )
      @remote_service_id = remote_service_id
      @shipping_method = shipping_method
      @amounts = amounts
      @delivery_date = delivery_date
      @warnings = warnings
      @errors = errors
      @data = data
      @original_request = original_request
      @original_response = original_response
    end

    def total_amount
      raise NoAmountsGiven if amounts.empty?

      amounts.map { |_name, amount| amount }.sum
    end
  end
end
