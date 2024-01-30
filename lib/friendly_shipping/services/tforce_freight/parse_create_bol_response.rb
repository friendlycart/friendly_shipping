# frozen_string_literal: true

require 'friendly_shipping/rate'
require 'friendly_shipping/api_result'
require 'friendly_shipping/services/tforce_freight/shipping_methods'

module FriendlyShipping
  module Services
    class TForceFreight
      # Parse a TForce Freight BOL response JSON into an ApiResult.
      class ParseCreateBOLResponse
        class << self
          # @param request [Request] the original request
          # @param response [RestClient::Response] the response to parse
          # @return [ApiResult<Hash>] the parsed result
          def call(request:, response:)
            json = JSON.parse(response.body)

            code = json.dig("summary", "code")
            message = json.dig("summary", "message")
            bol_id = json.dig("detail", "bolId")
            pro_number = json.dig("detail", "pro")
            documents = json.dig("detail", "documents", "image")&.map { _1.transform_keys(&:to_sym) }

            FriendlyShipping::ApiResult.new(
              {
                code: code,
                message: message,
                bol_id: bol_id,
                pro_number: pro_number,
                documents: documents
              },
              original_request: request,
              original_response: response
            )
          end
        end
      end
    end
  end
end
