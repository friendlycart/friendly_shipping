# frozen_string_literal: true

module FriendlyShipping
  class ApiErrorHandler
    extend Dry::Monads::Result::Mixin

    # @param [StandardError] error
    # @param [Object] original_request
    # @param [Object] original_response
    # @return [Dry::Monads::Failure<FriendlyShipping::ApiFailure>]
    def self.call(error, original_request: nil, original_response: nil)
      Failure(
        ApiFailure.new(
          error,
          original_request: original_request,
          original_response: original_response
        )
      )
    end
  end
end
