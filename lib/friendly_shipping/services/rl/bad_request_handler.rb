# frozen_string_literal: true

require 'friendly_shipping/services/rl/bad_request'

module FriendlyShipping
  module Services
    class RL
      class BadRequestHandler
        extend Dry::Monads::Result::Mixin

        # @param [RestClient::Exception] error
        # @param [FriendlyShipping::Request] original_request
        # @param [FriendlyShipping::Response] original_response
        # @return [
        #   Dry::Monads::Success<FriendlyShipping::ApiResult>,
        #   Dry::Monads::Failure<FriendlyShipping::ApiResult>
        # ]
        def self.call(error, original_request: nil, original_response: nil)
          if error.http_code == 400
            Failure(
              ApiFailure.new(
                BadRequest.new(error),
                original_request: original_request,
                original_response: original_response
              )
            )
          else
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
    end
  end
end
