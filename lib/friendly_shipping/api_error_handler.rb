# frozen_string_literal: true

require 'friendly_shipping/api_error'

module FriendlyShipping
  class ApiErrorHandler
    include Dry::Monads[:result]

    attr_reader :api_error_class

    # @param [Class] api_error_class
    def initialize(api_error_class: FriendlyShipping::ApiError)
      @api_error_class = api_error_class
    end

    # @param [StandardError] error
    # @param [FriendlyShipping::Request] original_request
    # @param [RestClient::Response] original_response
    # @return [Dry::Monads::Failure<FriendlyShipping::ApiFailure>]
    def call(error, original_request: nil, original_response: nil)
      Failure(
        ApiFailure.new(
          api_error_class.new(error),
          original_request: original_request,
          original_response: Response.new_from_rest_client_response(original_response)
        )
      )
    end
  end
end
