# frozen_string_literal: true

require 'friendly_shipping/rate'
require 'friendly_shipping/api_result'
require 'friendly_shipping/services/tforce_freight/shipping_methods'

module FriendlyShipping
  module Services
    class TForceFreight
      # Parses a pickup response into an `ApiResult`.
      class ParsePickupResponse
        class << self
          # @param request [Request] the original request
          # @param response [RestClient::Response] the response to parse
          # @return [ApiResult<Hash>] the parsed result
          def call(request:, response:)
            json = JSON.parse(response.body)

            response_status_code = json.dig("responseStatus", "code")
            response_status_description = json.dig("responseStatus", "description")
            transaction_id = json.dig("transactionReference", "transactionId")
            confirmation_number = json.dig("transactionReference", "confirmationNumber")
            email_sent = json.dig("transactionReference", "emailSent")
            origin_is_rural = json.dig("transactionReference", "originIsRural")
            destination_is_rural = json.dig("transactionReference", "destinationIsRural")

            FriendlyShipping::ApiResult.new(
              {
                response_status_code: response_status_code,
                response_status_description: response_status_description,
                transaction_id: transaction_id,
                confirmation_number: confirmation_number,
                email_sent: email_sent,
                origin_is_rural: origin_is_rural,
                destination_is_rural: destination_is_rural
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
