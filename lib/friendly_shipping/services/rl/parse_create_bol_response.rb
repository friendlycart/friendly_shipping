# frozen_string_literal: true

require 'json'
require 'friendly_shipping/services/rl/pickup_request'

module FriendlyShipping
  module Services
    class RL
      class ParseCreateBOLResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param [FriendlyShipping::Request] request
          # @param [FriendlyShipping::Response] response
          # @return [Dry::Monads::Result<ApiResult<PickupRequest>>]
          def call(request:, response:)
            parsed_json = JSON.parse(response.body)
            result = PickupRequest.new(
              pro_number: parsed_json['ProNumber'],
              pickup_request_number: parsed_json['PickupRequestNumber']
            )
            if result.valid?
              Success(
                ApiResult.new(
                  result,
                  original_request: request,
                  original_response: response
                )
              )
            else
              errors = parsed_json.fetch('Errors', [{ 'ErrorMessage' => 'Unknown error' }])
              Failure(
                ApiResult.new(
                  errors.map { |e| e['ErrorMessage'] },
                  original_request: request,
                  original_response: response
                )
              )
            end
          end
        end
      end
    end
  end
end
