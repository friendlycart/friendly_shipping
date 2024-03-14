# frozen_string_literal: true

require 'friendly_shipping/api_error'

module FriendlyShipping
  # Handles API errors by wrapping them in an API error class ({ApiError} by default) which
  # is then wrapped in an {ApiFailure} (along with the original API request and response).
  # Finally, the {ApiFailure} is then wrapped in a `Dry::Monads::Failure`.
  class ApiErrorHandler
    include Dry::Monads::Result::Mixin

    # @return [Class] the class used to wrap the API error
    attr_reader :api_error_class

    # @param api_error_class [Class] the class used to wrap the API error
    def initialize(api_error_class: FriendlyShipping::ApiError)
      @api_error_class = api_error_class
    end

    # @param error [StandardError] the error to handle
    # @param original_request [Request] the API request which triggered the error
    # @param original_response [RestClient::Response] the API response containing the error
    # @return [Failure<ApiFailure>]
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
