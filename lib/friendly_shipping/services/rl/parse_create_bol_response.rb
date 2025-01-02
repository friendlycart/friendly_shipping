# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Parses the response from the R+L API when creating a Bill of Lading (BOL).
      class ParseCreateBOLResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the request to attach to the API result
          # @param response [Response] the response to parse
          # @return [Result<ApiResult<ShipmentInformation>>] shipment info with the BOL document attached
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
