# frozen_string_literal: true

require 'friendly_shipping/api_error'

module FriendlyShipping
  class ApiErrorHandler
    include Dry::Monads::Result::Mixin

    attr_reader :api_error_class

    # @param [Class] api_error_class
    def initialize(api_error_class: FriendlyShipping::ApiError)
      @api_error_class = api_error_class
    end

    # @param [StandardError] error
    # @param [Object] original_request
    # @param [Object] original_response
    # @return [Dry::Monads::Failure<FriendlyShipping::ApiFailure>]
    def call(error, original_request: nil, original_response: nil)
      Failure(
        ApiFailure.new(
          api_error_class.new(error),
          original_request: original_request,
          original_response: original_response
        )
      )
    end
  end
end
