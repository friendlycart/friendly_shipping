# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class ParseAddressClassificationResponse
        extend Dry::Monads::Result::Mixin

        def self.call(request:, response:)
          parsing_result = ParseXMLResponse.call(
            request: request,
            response: response,
            expected_root_tag: 'AddressValidationResponse'
          )
          parsing_result.bind do |xml|
            address_type = xml.at('AddressClassification/Description')&.text&.downcase
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
