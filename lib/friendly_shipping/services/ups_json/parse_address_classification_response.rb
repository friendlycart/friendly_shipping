# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Parses the response of an address classification request.
      class ParseAddressClassificationResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the request that was sent
          # @param response [Response] the response received
          # @return [Result<ApiResult<String>>] the lowercased classification description (e.g. `"commercial"`),
          #   or nil if the response has none
          def call(request:, response:)
            parsed_response = ParseJsonResponse.call(
              request: request,
              response: response,
              expected_root_key: 'XAVResponse'
            )
            parsed_response.bind do |classification_response|
              address_type = classification_response.dig('XAVResponse', 'AddressClassification', 'Description')&.downcase
              Success(
                FriendlyShipping::ApiResult.new(
                  address_type,
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
