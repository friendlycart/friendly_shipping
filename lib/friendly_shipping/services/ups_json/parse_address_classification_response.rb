# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class ParseAddressClassificationResponse
        extend Dry::Monads::Result::Mixin

        class << self
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
