# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class ParseVoidResponse
        class << self
          def call(request:, response:, shipment:)
            parsed_response = ParseJsonResponse.call(
              request: request,
              response: response,
              expected_root_key: 'VoidShipmentResponse'
            )
            parsed_response.bind do |parsing_result|
              FriendlyShipping::ApiResult.new(
                parsed_response[:VoidShipmentResponse],
                original_request: request,
                original_response: response
              )
            end
          end
        end
      end
    end
  end
end
