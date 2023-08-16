# frozen_string_literal: true

require 'json'
require 'friendly_shipping/services/rl/shipment_information'

module FriendlyShipping
  module Services
    class RL
      class ParseCreateBOLResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param [FriendlyShipping::Request] request
          # @param [FriendlyShipping::Response] response
          # @return [Dry::Monads::Result<ApiResult<ShipmentInformation>>]
          def call(request:, response:)
            parsed_json = JSON.parse(response.body)
            shipment_info = ShipmentInformation.new(
              pro_number: parsed_json['ProNumber'],
              pickup_request_number: parsed_json['PickupRequestNumber']
            )
            if shipment_info.valid?
              Success(
                ApiResult.new(
                  shipment_info,
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
