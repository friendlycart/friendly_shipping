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
